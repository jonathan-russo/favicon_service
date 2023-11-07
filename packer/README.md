# Packer

This folder contains a packer configuration to create an AWS AMI with the software dependencies needed to run the favicon service.  This helps cut down on the boot time for a new server.  The AMI can be generated with the following commands:

```
packer init favicon-ami.pkr.hcl
packer inspect favicon-ami.pkr.hcl
packer validate favicon-ami.pkr.hcl
packer build favicon-ami.pkr.hcl
```