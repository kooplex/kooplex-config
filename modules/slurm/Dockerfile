FROM giovtorres/slurm-docker-cluster 

RUN yum install -y mailx sendmail

#COPY slurm.conf /etc/slurm/slurm.conf
#COPY slurmdbd.conf /etc/slurm/slurmdbd.conf

#COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
#RUN chmod a+x /usr/local/bin/docker-entrypoint.sh
#ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

CMD ["slurmctld"]
