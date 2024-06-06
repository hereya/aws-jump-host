# Hereya AWS JUMP HOST

A [hereya](https://github.com/hereya/hereya-cli) package that deploy an EC2 instance for serving as Jump host.

The Jump host is particularly useful for creating ssh tunnels to connect to not publicly accessible resources such as databases.

## Usage

It is useful to install this package in a workspace so that it is not deployed as a project package. 

```bash
hereya workspace install -w <workspace> hereya/aws-jump-host
```

This package exports all the necessary data to create an ssh tunnel such as `jumpHostPublicIp`, `jumpHostUser` and `jumpHostSshPrivateKey`, the ssh private key of the host in pem format.

### Example
For example, to create an ssh tunnel for connecting to document db, one can proceed as follows:

* Store the private key in a file: 
```bash
hereya workspace env jumpHostSshPrivateKey -w <workspace> > key.pem
```
* Give the appropriate permissions to the file
```bash
chmod 400 key.pem
```

* Start you tunnel
```bash
export DOCUMENTDB_HOST=<your document db database host>
export LOCAL_PORT=27017 # change this accordingly
export REMOTE_PORT=27017
export USER=<jumpHostUser> # hereya workspace env jumpHostUser -w <workspace>
export HOST=<jumpHostPublicIp> # hereya workspace env jumpHostPublicIp -w <workspace>
ssh -i key.pem -L ${LOCAL_PORT}:${DOCUMENTDB_HOST}:${REMOTE_PORT} ${USER}@${HOST} -N
```
