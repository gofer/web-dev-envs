# Webアプリケーション開発のための環境整備

## DNSサーバー
NSD + UnboundでDNSサーバーを構築した。
`dns/zones`以下にゾーンファイルを配置して構築する。
ホストのネットワークアダプターのDNSサーバーを`127.0.0.1`に設定すれば良い。

## プライベート認証局
OpenSSLでプライベート認証局を構築した。
証明書の管理とOCSPレスポンダーをOpenSSLで，CRL配布ポイントをNginxで構築した。
OCSPレスポンダー，CRL配布ポイント共にリバースプロキシ経由でアクセスする。

### 起動手順
- `ca/resource/ssl/opnessl.cnf.sample`をコピーして`ca/resource/ssl/opnessl.cnf`を編集する
- `ca/.env`，`ca/.secret`を編集する

## リバースプロキシ
Nginxでリバースプロキシを構築した。

### 注意点
- SSLの証明書は起動時には存在しないのでとりあえず自己署名証明書を
  - 秘密鍵: `/etc/ssl/private/fake_self_signed.pem`
  - 証明書: `/etc/ssl/certs/fake_self_signed.crt`
  に配置している。
- Nginxの設定には
  > ```nginx.conf
  > ssl_certificate      /etc/ssl/certs/ fake_self_signed.crt;
  > ssl_certificate_key  /etc/ssl/private/fake_self_signed.pem;
  > ```
  としておく。
