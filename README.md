# Cloudwatch sync

Create or Update Cloudwatch alarms from yaml conf

## Dependencies

  Ruby 1.9.3 or newer

## install & setup

  bundle install --path vendor/bundle
  cp config/cloudwatch.sample.yml config/cloudwatch.yml

## Conf Sample

see: config/cloudwatch.sample.yml

## Usage

**Sync alarms**

```shell
AWS_ACCESS_KEY_ID=xxxxxxxxx AWS_SECRET_ACCESS_KEY=xxxxxxxx AWS_REGION=<us-east-1|ap-notrh-east-1|...> bundle exec ruby bin/cloudwatch_sync.rb sync
```

**Sync specified alarms**

```shell
AWS_ACCESS_KEY_ID=xxxxxxxxx AWS_SECRET_ACCESS_KEY=xxxxxxxx AWS_REGION=<us-east-1|ap-notrh-east-1|...> bundle exec ruby bin/cloudwatch_sync.rb sync <ec2|rds|elastic_cache>
```

**list alarms**

```shell
AWS_ACCESS_KEY_ID=xxxxxxxxx AWS_SECRET_ACCESS_KEY=xxxxxxxx AWS_REGION=<us-east-1|ap-notrh-east-1|...> bundle exec ruby bin/cloudwatch_sync.rb list
```

