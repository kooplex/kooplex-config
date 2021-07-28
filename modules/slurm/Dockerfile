FROM giovtorres/slurm-docker-cluster 

RUN yum install -y mailx sendmail nss-pam-ldapd.x86_64
RUN groupadd nslcd &&  sed -i -e "s,passwd.*,passwd: ldap compat systemd," -e "s,group.*,group: ldap compat systemd," /etc/nsswitch.conf

CMD ["slurmctld"]
