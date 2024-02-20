# メールサーバ作成

## メールサーバ種類

### 送信用サーバ
* SMTPサーバ
* Postfix（メール送信、転送用）

### 受信用サーバ
* POP3サーバ
* IMAP4サーバ

### POP3とIMAP4サーバの違い
```
POP3はメールが、端末のメールソフトを通して自分のパソコン上に取り込まれます。このことから、インターネットに繋がっていなくとも、パソコンからメールの中身を確認できます。しかし、これは逆にメールを受信したパソコン上でしかメールを確認できないため、他の端末での確認はできません。
```
```
IMAP4は、ブラウザを通してサーバーに直接メールを読み込みます。POP3と違って、インターネットが繋がっていないとメールの確認ができませんが、逆にネットが繋がれば他の端末からメールを読み込むことができます。
```

### Amazon SES（Simple Email Service）
```
本来、メール受信の際にPOP3やIMAP4を利用することが一般的ですが、SESはこれらが含まれていません。よってクライアントを使ったメール受信ができません。しかし、SESを使うことによって、他のメールサーバーとの通信、メールの拒否、スパムやウイルスのスキャンといった、様々なメリットがあります。
```

## 作成方法
参考：[サイト](https://blog.denet.co.jp/ec2-postfix-dovecot-mail-server-setup/)、
[踏み台サーバを経由してプライベートサブネットにあるEC2インスタンスに接続する方法](https://zenn.dev/devcamp/articles/3c08827387cfb9)

### AWSリソースを構成
1. main-使用するリージョンの設定（プロバイダ設定）
2. VPC作成
3. InternetGateway作成
4. Routetable作成
5. Subnet作成
6. SecurityGroup作成
7. EC2作成

### 踏み台に接続
1. publicSubnet内に作成したEC2インスタンスに接続
2. public用インスタンス内から、privateSubnet内に作成したEC2インスタンスに接続
   1. その際に秘密鍵が必要になるため、予めpublic用インスタンス内にprivateインスタンス接続用の秘密鍵を配置しておく必要がある。
   2. 配置方法は以下
      1. ローカルから、以下コマンドを実行
            ```text
            scp -i [publicインスタンスに接続する秘密鍵を指定] [privateインスタンス接続に使用する秘密鍵ファイルを指定] [ubuntu or ec2-user or etc.]@[publicインスタンスのパブリックIPv4アドレスを指定]:~/.ssh
            ```
3. 一旦完了

### SMTPサーバー構築(Postfix)
#### Postfix導入
1. EC2インスタンスにSSH接続し、rootユーザーに切り替えます。
   ```text
   sudo su -
   ```
2. すべてのパッケージをアップデート
   ```text
   apt -y update
   ```
   ※ubuntu→apt、centos→tumに置換してください。
3. Postfixをインストール
   ```text
   apt install postfix
   apt-get install postfix
   ```
   ※どちらでも実行可能
   ※No configurationを選択する
4. インストールされているか確認
   ```text
   apt list --installed | grep postfix
   ```
#### 設定ファイル編集
参考：[サイト①](https://www.servernote.net/article.cgi?id=postfix-setup-note)
1. /etc/postfix/に移動
   ```text
   cd /etc/postfix/
   ```
2. Postfixの設定ファイルである"main.cf.proto" or "main.cf"、"master.cf" or "master.cf.proto"があるかを確認
   ```text
   ls -la
   ```
3. バックアップを作成
   ```text
   cp -p main.cf.proto main.cf
   cp -p master.cf.proto master.cf
   ```
   ※-pは	パーミッションと所有者とタイムスタンプを保持する（--preserve=mode,ownership,timestamps相当）
4. main.cfを編集する
   ```text
   vi main.cf
   ```
   1. myhostname <br>
   SMTPサーバーのホスト名をFQDN（ホスト名＋ドメイン名）で設定します。
      ```text
      #myhostname = host.domain.tld
      #myhostname = virtual.domain.tld
      ↓
      #myhostname = host.domain.tld
      #myhostname = virtual.domain.tld
      myhostname = test-hostname.test-domain.com (追加します)
      ```
   2. mydomain <br>
   SMTPサーバーが属するドメイン名を指定します。
      ```text
      #mydomain = domain.tld
      ↓
      #mydomain = domain.tld
      mydomain = test-domain.com (追加します)
      ```
   3. myorigin <br>
   ローカルからのメール送信時、送信元メールアドレス@以降にドメイン名を付加させるように設定します。
      ```text
      #myorigin = $myhostname
      #myorigin = $mydomain
      ↓
      #myorigin = $myhostname
      myorigin = $mydomain (先頭のコメントアウト "#" を外します)
      ```
   4. mydestination <br>
   SMTPサーバーがメールをローカルで受信するドメイン名を指定します。
      ```text
      mydestination = $myhostname, localhost.$mydomain, localhost
      #mydestination = $myhostname, localhost.$mydomain, localhost, $mydomain
      #mydestination = $myhostname, localhost.$mydomain, localhost, $mydomain,
      ↓
      #mydestination = $myhostname, localhost.$mydomain, localhost ("#"がついていなければコメントアウト "#" します)
      mydestination = $myhostname, localhost.$mydomain, localhost, $mydomain (先頭のコメントアウト "#" を外します)
      #mydestination = $myhostname, localhost.$mydomain, localhost, $mydomain,
      ```
   5. mynetworks <br>
   VPCのネットワークと自分自身からは無条件で転送するように設定します。
      ```text
      #mynetworks = $config_directory/mynetworks
      #mynetworks = hash:/etc/postfix/network_table
      ↓
      #mynetworks = $config_directory/mynetworks
      #mynetworks = hash:/etc/postfix/network_table
      mynetworks = 10.0.0.0/16 (追加します)
      ```
   6. smtpd_banner <br>
   Telnet等でアクセスした際のバナー情報、バージョンを非表示にします。
      ```text
      #smtpd_banner = $myhostname ESMTP $mail_name
      #smtpd_banner = $myhostname ESMTP $mail_name ($mail_version)
      smtpd_banner = $myhostname ESMTP $mail_name (Ubuntu)
      ↓
      #smtpd_banner = $myhostname ESMTP $mail_name
      #smtpd_banner = $myhostname ESMTP $mail_name ($mail_version)
      #smtpd_banner = $myhostname ESMTP $mail_name (Ubuntu) (コメントアウト "#" します)
      smtpd_banner = $myhostname ESMTP unknown (追加します)
      ```
   7. home_mailbox <br>
   メールボックスの形式を Maildir形式 に指定します。
      ```text
      #home_mailbox = Mailbox
      #home_mailbox = Maildir/
      ↓
      #home_mailbox = Mailbox
      home_mailbox = Maildir/ (先頭のコメントアウト "#" を外します)
      ```
   8. setgid_group <br>
   Postfixが起動する際に使用するグループを指定します。<br>
   デフォルトでは、この値は "postdrop" に設定されています。
      ```text
      setgid_group =
      ↓
      #setgid_group = (コメントアウト "#" します)
      ```
   9. sendmail_path <br>
   Postfixがsendmail互換のコマンドを実行するためのパスを指定します。<br>
   デフォルトでは、この値は "/usr/sbin/sendmail" に設定されています。
      ```text
      sendmail_path =
      ↓
      #sendmail_path = (コメントアウト "#" します)
      ```
   10. mailq_path <br>
   Postfixがmail queue listingコマンドを実行するためのパスを指定します。<br>
   デフォルトでは、この値は "/usr/bin/mailq" に設定されています。
         ```text
         mailq_path =
         ↓
         #mailq_path = (コメントアウト "#" します)
         ```
   11. newaliases_path <br>
   Postfixがaliasデータベースを構築するためのコマンドを実行するパスを指定します。<br>
   デフォルトでは、この値は "/usr/bin/newaliases" に設定されています。
         ```text
         newaliases_path =
         ↓
         newaliases_path = (コメントアウト "#" します)
         ```
   12. manpage_directory <br>
   Postfixのマニュアルページが格納されているディレクトリのパスを指定します。<br>
   デフォルトでは、この値は "/usr/share/man" に設定されています。
         ```text
         manpage_directory =
         ↓
         manpage_directory = (コメントアウト "#" します)
         ```
   13. sample_directory <br>
   Postfixのサンプル設定ファイルが格納されているディレクトリのパスを指定します。<br>
   デフォルトでは、この値は "/usr/share/doc/postfix/examples" に設定されています。
         ```text
         sample_directory =
         ↓
         sample_directory = (コメントアウト "#" します)
         ```
   14. readme_directory <br>
   PostfixのREADMEファイルが格納されているディレクトリのパスを指定します。<br>
   デフォルトでは、この値は "/usr/share/doc/postfix" に設定されています。
         ```text
         readme_directory =
         ↓
         readme_directory = (コメントアウト "#" します)
         ```
   15. html_directory <br>
   PostfixのHTMLドキュメンテーションが格納されているディレクトリのパスを指定します。<br>
   デフォルトでは、この値は "/usr/share/doc/postfix/html" に設定されています。
         ```text
         html_directory =
         ↓
         html_directory = (コメントアウト "#" します)
         ```
5. ここまで設定できたらファイルを保存して閉じます。
6. 設定した値をバックアップと比較して確認してみます。
   ```text
   diff main.cf.proto main.cf
   ```
7. 書式チェック
   ```text
   postfix check
   ```
   ※エラーが出なければ、OK
8. Postfixの起動と自動起動設定を行います。
   1. Postfixの起動状態を確認
      ```text
      systemctl enable --now postfix
      ```
      enableオプションは、システムの起動時にサービスを自動的に開始するように」systemdに支持する。 <br>
      --nowフラグは、サービスをすぐに起動すること。
   2. Postfixの起動状態を確認
      ```text
      systemctl status postfix
      ```
      「Active: active (running)」となっていれば問題なく起動している <br>
      「Loaded: ~ postfix.service;」の横が「enabled;」となっていれば自動起動が有効化できている
   3. 25番ポート(SMTP) が 「LISTEN」 状態（接続待ち）になっているか確認
      ```text
      ss -atn | grep 25
      ```
9.  メールユーザー作成 <br>
メール受信用にユーザーを作成していきます。<br>
まずは新規ユーザー追加時に自動でMaildir形式メールボックス作成するように設定します。
      ```text
      sudo mkdir -p /etc/skel/Maildir/{new,cur,tmp}
      ```
10. メールボックスのパーミッションを変更します。
      ```text
      chmod -R 700 /etc/skel/Maildir/
      ```
11. ユーザを作成
      ```text
      adduser hiro-mail
      ```
      ※useraddではありません。
12. PWの設定
      ```text
      passwd hiro-mail
      ```
      ※設定値は任意。
13. PW設定後に、先ほどの作成したディレクトリがユーザ配下に作成されていることを確認する
      ```text
      ll /home/hiro-mail/Maildir/
      ```
      ※ディレクトリが作成されていない場合や<br>
      /home/配下にユーザディレクトリが作成されていない場合は、「useradd」でユーザを作成している可能性があります。

### Postfix動作確認
ローカル環境下のメールテストを行うため telnet をインストールします。

#### telnetとは。
telnet でサーバへ接続すると、サーバを直接操作できるようになります。
telnetでメールサーバに接続し、メールサーバから直接メールを送信することでメールサーバが正常に動作していることを確認します。

1. telnetをインストールします。
   ```text
   apt install telnet
   ```
   ※centosは、「yum」
2. 自身のメールサーバに接続
   ```text
   telnet localhost 25
   ```
   ※接続に成功すればコード220の応答があります。
3. SMTPコマンドでheloを使用し、自分のメールサーバとセッションを開始して、送信元メールアドレスを確認する
   ```text
   helo localhost
   ```
   ※実行成功すると、「250 *******.com」が返ってくる
4. mail from: コマンドで送信元メールアドレスを入力します。
   ```text
   mail from:aws-mail-server.awsforstudy-hiro.com
   ```
   ※実行成功すると、「250 2.1.0 ok」が返ってくる
5. rcpt to: コマンドで送信先メールアドレスを入力します。
   ```text
   rcpt to:aws-mail-server.awsforstudy-hiro.com
   ```
6. hoge


## Ubuntuでuseraddでホームディレクトリが作成されない場合

[参考](https://ex1.m-yabe.com/archives/3259)

Ubutnuは標準でホームディレクトリを作成する設定ではありません。

ホームディレクトリを作成するのは「/etc/login.defs」内に設定がありますが、Ubuntuだと「CREATE_HOME yes」の設定がないのでホームディレクトリが作成されないとのことです。

そのため、Ubuntuでは「useradd」ではなく、「adduser」を使用する。
adduserコマンドを利用すると、PW発行からホームディレクトリ作成まで対話式に進められる。
<br>
<br>
<br>
<br>
<br>
<br>
<br>
============postfixインストール時に聞かれるやつ===================

Please select the mail server configuration type that best meets your needs.

No configuration:
Should be chosen to leave the current configuration unchanged.
Internet site:
Mail is sent and received directly using SMTP.
Internet with smarthost:
Mail is received directly using SMTP or by running a utility such as fetchmail. Outgoing mail is sent using a smarthost.
Satellite system:
All mail is sent to another machine, called a 'smarthost', for delivery.
Local only:
The only delivered mail is the mail for local users. There is no network.

===============================================================






