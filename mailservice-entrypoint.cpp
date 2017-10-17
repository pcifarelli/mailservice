#include <unistd.h>
#include <signal.h>
#include <stdlib.h>
#include <sys/wait.h>
#include <iostream>
#include <string.h>
#include <cstdlib>

// Effects a graceful shutdown of postfix (for use as an entrypoint in a docker)
// also: starts a syslogger and tails the maillog

void start_command(const char *);
void stop_command(const char *);
pid_t tail_log(const char *log);

// signal handler for TERM
bool quittin_time = false;
void term_sigaction(int signo, siginfo_t *sinfo, void *arg);

int main(int argc, char** argv)
{
    // setup the signal handler for TERM
    struct sigaction termaction;
    termaction.sa_sigaction = term_sigaction;
    termaction.sa_flags = SA_SIGINFO;
    sigemptyset(&termaction.sa_mask);
    sigaction(SIGTERM, &termaction, 0);
    sigaction(SIGINT, &termaction, 0);
    sigaction(SIGQUIT, &termaction, 0);

    const char *setup_cmd = "/container/bin/setup.sh";
    const char *rsyslog_cmd = "/container/bin/rsyslog.sh";
    const char *loadkey_cmd = "/container/bin/load_key.py";
    const char *saslauthd_cmd = "/container/bin/saslauthd.sh";
    const char *postfix_cmd = "/container/bin/postfix.sh";
    const char *dovecot_cmd = "/container/bin/dovecot.sh";

    const char *cmds[10];
    memset(cmds, 0, sizeof(cmds));
    const char *cmd_instruction = std::getenv("CMDS");

    if (!cmd_instruction)
    {
        if (argc > 1)
           cmd_instruction = argv[1];
        else
           cmd_instruction = "all";
    }

    if (!strncmp(cmd_instruction, "dovecot", 7))
    {
        std::cout << "Only dovecot will be started in this container" << std::endl;
        cmds[0] = dovecot_cmd;
    }
    else if (!strncmp(cmd_instruction, "postfix", 7))
    {
        std::cout << "Only postfix/saslauthd will be started in this container" << std::endl;
        cmds[0] = saslauthd_cmd;
        cmds[1] = postfix_cmd;
    }
    else if (!strncmp(cmd_instruction, "all", 3))
    {
        std::cout << "dovecot/postfix/saslauthd will all be started" << std::endl;
        cmds[0] = saslauthd_cmd;
        cmds[1] = postfix_cmd;
        cmds[2] = dovecot_cmd;
    }
    else
        std::cout << "Unrecognized arg [" << cmd_instruction << "] - nothing started" << std::endl;

    start_command(setup_cmd);
    start_command(rsyslog_cmd);
    pid_t logpid = tail_log("/var/log/maillog");

    system(loadkey_cmd);
    int i = 0;
    while (cmds[i])
    {
       start_command(cmds[i]);
       i++;
    }

    while (!quittin_time)
        sleep(2);

    std::cout << "Quittin time" << std::endl;

    while (cmds[i])
    {
       stop_command(cmds[i]);
       i++;
    }

    stop_command(rsyslog_cmd);

    sleep(1);
    kill(logpid, SIGTERM);
}


void term_sigaction(int signo, siginfo_t *, void *)
{
    quittin_time = true;
}

pid_t tail_log(const char *log)
{
   pid_t pid;

   if ( (pid = fork()) < 0 )
      std::cerr << "Unable to start postfix, fork failed!" << std::endl;
   else if (pid == 0) 
      execl("/usr/bin/tail", "tail", "-f", log, (const char *) 0);

   return pid;
}


void run_op(const char *cmd, const char *op)
{
   pid_t pid;

   if ( (pid = fork()) < 0 )
      std::cerr << "Unable to start postfix, fork failed!" << std::endl;
   else if (pid == 0) 
      execl("/bin/sh", "sh", cmd, op, (const char *) 0);
   else
   {
      // parents should wait for their children
      int status = 0;
      pid_t p = waitpid(pid, &status, 0);
   }
}

void start_command(const char *cmd)
{
   run_op(cmd, "start");
}

void stop_command(const char *cmd)
{
   run_op(cmd, "stop");
}

