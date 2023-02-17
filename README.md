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
❯ make

Usage:
make <target>
  all              🚀 Build dependencies and run all auditing tools 🔒🔍

Deps
install-deps     ❌ (out of scope) Install git and docker if you want to continue
build-n-run      🛠️ 🐳 Build and start the containers

Audit
audit            🔥 Fire up all auditing tools (Prowler, ScoutSuite, CloudSplaining, PMapper, CloudSploit)
cloudsplaining   🔍 Audit AWS account with CloudSplaining
pmapper          🔍 Evaluate IAM permissions in AWS
prowler          🔍 Audit AWS account with Prowler v3
prowler-v2       🔍 Audit AWS account with Prowler v2
scoutsuite       🔍 Audit AWS account with ScoutSuite
cloudsploit      🔍 Audit AWS account with CloudSploit
gather-results   💾 Copy all scan results locally in auditbox-results directory

Cleanup
clean            🧹 Delete scan results, stop and delete containers

Debug
restart          🔄 Restart all containers
dexec            (Debug) Docker exec into auditbox

Helpers
help             ❔ Display this help menu
```


