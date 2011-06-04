Chef-solo Quickstart
==================================

Vagrant で壊してもいい仮想マシンを用意する。
----------------------------------
    vagrant up

まず、実行できるようにする。
----------------------------------
下記のコマンドが chef-solo を実行するコマンドだ。
これから、このコマンドを実行するための材料を作っていく。

    chef-solo -c ~/solo.rb -j node.json

chef-solo のオプションはそれぞれ下記の通り。

    -c, --config CONFIG
    -j, --json-attributes JSON_ATTRIBS
    -r, --recipe-url RECIPE_URL

### root になる
    sudo -s

### 設定ファイル(solo.rb)を用意する。

    file_cache_path "/root/chef-solo"
    cookbook_path "/root/chef-solo/cookbooks"

### Node アトリビュート(node.json)を用意する。

    {
      "resolver": {
        "nameservers": [ "10.0.0.1" ],
        "search":"int.example.com"
      },
      "run_list": [ "recipe[resolver]" ]
    }

### cookbook を配置しておく。

`solo.rb`で指定した、`cookbook_path` ディレクトリ配下に、cookbook を配置しておく。
今回は、resolver を使用するので、resolver を配置しておく。

    git clone https://github.com/opscode/cookbooks.git opscode-cookbooks
    cp -r opscode-cookbooks/resolver chef-solo/cookbooks

### そしてついに実行！

    vagrant  ~ # chef-solo -c solo.rb -j node.json
    [Sat, 04 Jun 2011 03:22:13 -0700] INFO: Setting the run_list to ["recipe[resolver]"] from JSON
    [Sat, 04 Jun 2011 03:22:13 -0700] INFO: Starting Chef Run (Version 0.9.12)
    [Sat, 04 Jun 2011 03:22:13 -0700] INFO: Chef Run complete in 0.011504 seconds
    [Sat, 04 Jun 2011 03:22:13 -0700] INFO: cleaning the checksum cache
    [Sat, 04 Jun 2011 03:22:13 -0700] INFO: Running report handlers
    [Sat, 04 Jun 2011 03:22:13 -0700] INFO: Report handlers complete
    vagrant  ~ #


自分で、cookbook を作ってみる。
----------------------------------

    mkdir -p chef-solo/cookbooks/main/recipes
    vim chef-solo/cookbooks/main/recipes/default.rb

chef-solo/cookbooks/main/recipes/default.rb

    directory "/this/is/very/nested/directory" do
      owner "root"
      group "root"
      recursive true
    end
    file "/tmp/something" do
      owner "root"
      group "root"
      mode "0755"
      action :delete
    end

オプションなしで(つまり `chef-solo` だけで)同じことができる様にする。
----------------------------------
オプションを指定せず、`chef-solo`を実行しても、さっきの `chef-solo -c solo.rb -j node.json` と同じ事ができるようにしてみる。

    mkdir /root/wwwroot
    mv node.json wwwroot
    cd chef-solo
    tar czf ../wwwroot/chef-solo.tgz cookbooks
    cd ../
    rm -rf chef-solo

### 設定ファイル(solo.rb)をデフォルトの場所に配置する。

これで`-c solo.rb`が不要になる。

    mkdir /etc/chef/
    mv solo.rb /etc/chef
    vi /etc/chef/solo.rb

* /etc/chef/solo.rb の中身

    file_cache_path "/root/chef-solo"
    cookbook_path   "/root/chef-solo/cookbooks"
    json_attribs    "http://localhost:8000/node.json"
    recipe_url      "http://localhost:8000/chef-solo.tgz"

### wwwroot をHTTPで公開する。
8000番ポートで、HTTP サーバが起動し、wwwroot 配下が公開される。

    cd wwwroot
    python -m SimpleHTTPServer

### そしてついに実行！
    chef-solo

Role を作ってみる。
==================================
    mkdir chef-solo/roles
    vim chef-solo/roles/test.rb

chef-solo/roles/test.rb

    name 'test'
    description 'This is just a test role, no big deal.'
    run_list(
      'recipe[main]'
    )

これを読む
----------------------------------
* [ChefSolo](http://wiki.opscode.com/display/chef/Chef+Solo)

* [Attribute](http://wiki.opscode.com/display/chef/Attributes)  
いろいろなところで参照する変数みたいなもん。
Attributes は様々なレベルで設定される。
  * cookbooks
  * environments (Chef 0.10.0 or above only)
  * roles
  * nodes


* [Nodes](http://wiki.opscode.com/display/chef/Nodes)

* [Resources](http://wiki.opscode.com/display/chef/Resources)  
Resources は Puppet で言う Type みたいなもの。インフラを記述する基本単位。これが　Chef DSLの超ベースの部分。

* [Recipes](http://wiki.opscode.com/display/chef/Recipes)  
レシピは関係性の深い定義をセットにしたもの。Pupppet のモジュールに対応する。
例えば、apache のレシピでは、apache の package のインストールや、 httpd.conf の template(=httpd.conf.erb)、その  
template の中で使われる属性値(=Attribute)のファイルが下記のような感じで配置される。

    apache2/attributes/default.rb
    apache/recipes/default.rb
    apache/templates/default/httpd.conf.erb

* [Cookbooks](http://wiki.opscode.com/display/chef/Cookbooks)  
Cookbook は Recipe を集めたもの。つまりレシピ集。

* [ Anatomy of Chef Run ](http://wiki.opscode.com/display/chef/Anatomy+of+a+Chef+Run)
