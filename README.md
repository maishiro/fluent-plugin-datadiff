# fluent-plugin-datadiff

Fluentd で 前後レコードのデータ間で差分をとった値をレコードに追加するプラグイン

## Install

lib/fluent/pluginフォルダに filter_datadiff.rb ファイルを配置する

## Configuration

### Example:
    <source>
      forward
    </source>
    
    <filter **>
      type datadiff
      diff_idx_key a,b
      key_diff c
      key_add d
      time_format %Y/%m/%d %H:%M:%S
    </filter>
    
    <match **>
      type stdout
    </match>

Assuming following inputs are coming:

    $ echo '{"a":"foo","b":"bar","c":"2016/07/01 00:00:00"}' | fluent-cat raw.test
    $ echo '{"a":"foo","b":"bar","c":"2016/07/01 00:00:10"}' | fluent-cat raw.test
    $ echo '{"a":"foo","b":"bar","c":"2016/07/01 00:01:00"}' | fluent-cat raw.test

then output bocomes as belows (like, | grep WARN | grep -v favicon):

    raw.test: {"a":"foo","b":"bar","c":"2016/07/01 00:00:00","d":10}
    raw.test: {"a":"foo","b":"bar","c":"2016/07/01 00:00:10","d":50}

## Parameters

- diff_idx_key

    差分をとるレコードのグループ化。コンマ区切りで複数を結合可能。

- key_diff

    差分をとるデータアイテム

- key_add

    差分値をレコードに追加するときの名前

- time_format (optional)

    差分をとるアイテムが日時形式のときに時間フォーマットを指定する


