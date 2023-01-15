# AuditBox

Automating the AWS auditing process.

## Tools

- [x] [CloudSplaining](https://github.com/salesforce/cloudsplaining)
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
❯ make help
all                            🚀 Build dependencies and start security audits 🔒🔍
audit                          🛡️ Audit AWS account with all the tools (Prowler, ScoutSuite, CloudSplaining, PMapper)
build-n-run                    🛠️ 🐳 Build and start the containers
clean                          🧹 Delete scan results, stop and delete containers
cloudsplaining                 🔍 Audit AWS account with CloudSplaining
gather-results                 💾 Copy all scan results locally in auditbox-results directory
help                           ❔ Display this help screen
install-deps                   ❌ (out of scope) Install git and docker if you want to continue
pmapper                        🔍 Evaluate IAM permissions in AWS
prowler                        🔍 Audit AWS account with Prowler
scoutsuite                     🔍 Audit AWS account with ScoutSuite
```


