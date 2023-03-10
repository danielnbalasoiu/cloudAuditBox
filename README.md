# AuditBox

Automating the AWS auditing process.

## Tools

- [x] [CloudSplaining](https://github.com/salesforce/cloudsplaining)
- [x] [CloudSploit](https://github.com/aquasecurity/cloudsploit)
- [x] [PMapper](https://github.com/nccgroup/PMapper)
- [x] [Prowler](https://github.com/prowler-cloud/prowler)
- [x] [ScoutSuite](https://github.com/nccgroup/ScoutSuite)


## Usage

1. Clone the repository.

```shell
git clone git@github.com:danielnbalasoiu/auditBox.git && cd auditBox
```

2. Copy or rename `env.list.example` to `env.list`.

```shell
cp env.list.example env.list
```

3. Replace `REDACTED` values with your own.
4. Run the audit

```shell
make all
```

5. Check audit results stored inside `auditbox-results` directory.

### Help

```shell
โฏ make

Usage:
make <target>
  all              ๐ Build dependencies and run all auditing tools ๐๐

Deps
install-deps     โ (out of scope) Install git and docker if you want to continue
build-n-run      ๐ ๏ธ ๐ณ Build and start the containers

Audit
audit            ๐ฅ Fire up all auditing tools (Prowler, ScoutSuite, CloudSplaining, PMapper, CloudSploit)
cloudsplaining   ๐ Audit AWS account with CloudSplaining
pmapper          ๐ Evaluate IAM permissions in AWS
prowler          ๐ Audit AWS account with Prowler v3
prowler-v2       ๐ Audit AWS account with Prowler v2
scoutsuite       ๐ Audit AWS account with ScoutSuite
cloudsploit      ๐ Audit AWS account with CloudSploit
gather-results   ๐พ Copy all scan results locally in auditbox-results directory

Cleanup
clean            ๐งน Delete scan results, stop and delete containers

Debug
restart          ๐ Restart all containers
dexec            (Debug) Docker exec into auditbox

Helpers
help             โ Display this help menu
```


