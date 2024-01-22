FROM ubuntu:latest

# Install SSH
RUN apt-get update && apt-get install -y openssh-server
RUN mkdir /var/run/sshd

# Add a user and set a default password
RUN useradd -m ansible_user && echo "ansible_user:ansible" | chpasswd

# Create the .ssh directory for ansible_user
RUN mkdir -p /home/ansible_user/.ssh

# Copy the public key to the authorized_keys file
COPY id_ed25519.pub /home/ansible_user/.ssh/authorized_keys

# Set the correct permissions on the .ssh directory and authorized_keys file
RUN chmod 700 /home/ansible_user/.ssh && \
    chmod 600 /home/ansible_user/.ssh/authorized_keys

# Set the owner of the .ssh directory and its contents to ansible_user
RUN chown -R ansible_user:ansible_user /home/ansible_user/.ssh

# SSH login fix to prevent Disconnected: No supported authentication methods available
RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

# Expose the SSH port
EXPOSE 22

# Start the SSH service
CMD ["/usr/sbin/sshd", "-D"]