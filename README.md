# Vagrant environment for Symfony

This project provides a virtual environment for Symfony development using
[Vagrant](https://www.vagrantup.com).

## What's in the box?

When you start Vagrant, this environment will provide the following tools
that can be useful when developing for Symfony2:

- Git
- cURL
- MySQL
  * Username: `root`
  * Password: empty
- SQLite
- nginx
- PHP
- PHP-FPM
- APC
- PEAR
- XDebug
- Beanstalkd
- Memcached
- Node.js:
  + less,
  + casperjs, 
  + phantomjs, 
  + bower, 
  + gulp.

Additionally, it will create a MySQL database called `cp` that a Symfony
application can connect to without any configuration.

## Usage and requirements

### Ansible

[Ansible](http://ansible.com) is used to provision the virtual machine, so you
must have that installed. Follow the
[installation instructions](http://docs.ansible.com/intro_installation.html#installation).

### Usage

Installation is as easy as cloning a GitHub project:

```
$ git clone https://github.com/kleiram/vagrant-symfony.git vagrant
$ cd vagrant/sources
$ git clone {your project}
```

After the project is added, you can start the environment like this:

```
$ cd vagrant
$ vagrant up
```

Starting the VM might take some time, since it will download the entire box
and additional applications/library. When the VM is done setting up, point
your browser towards [http://192.168.33.10](http://192.168.33.10) and there you
have it: Symfony.

#### Note

If you're using Windows, you have to modify the `Vagrantfile` a little bit to
make it all work (since Windows doesn't support NFS). Replace the following
lines in the Vagrantfile:

```ruby
config.vm.synced_folder ".",  "/vagrant", id: "vagrant-root", :nfs => true
config.vm.synced_folder "./sources/", "/var/www", id: "application",  :nfs => true
```

with:

```ruby
config.vm.synced_folder ".",  "/vagrant", id: "vagrant-root"
config.vm.synced_folder "./sources/", "/var/www", id: "application"
```

## //@TODO:

Make it possible to create virtual hosts by adding new section to [site.yml](./ansible/site.yml)

## Troubleshooting

### I'm not allowed to access my site?

If you visit your site and you get the following error message:

```
You are not allowed to access this file. Check app_dev.php for more information.
```

You have to remove the following lines from `web/app_dev.php`:

```php
if (isset($_SERVER['HTTP_CLIENT_IP'])
    || isset($_SERVER['HTTP_X_FORWARDED_FOR'])
    || !in_array(@$_SERVER['REMOTE_ADDR'], array('127.0.0.1', 'fe80::1', '::1'))
) {
    header('HTTP/1.0 403 Forbidden');
    exit('You are not allowed to access this file. Check '.basename(__FILE__).' for more information.');
}
```

### Why is my site so slow?

If your site is noticeably slow (and I'm talking hundreds of milliseconds), it's
because the caching and logging is taking it's time (NFS synchronization). One
way to fix this is by changing the cache folder in the `app/AppKernel.php` file.
At the end of the AppKernel class, add the following methods:

```php
public function getCacheDir()
{
    return '/tmp/symfony/cache/'. $this->environment;
}

public function getLogDir()
{
    return '/tmp/symfony/log/'. $this->environment;
}
```

This will change the location of the `cache` and `log` directories you normally
find in the `app` directory of Symfony to the `/tmp/symfony` directory. This
will speed up your site _a lot_. The downside is that you won't be able to check
the log from your host computer (the computer that's running Vagrant).

## Credits

Thanks [@kleiram](https://github.com/kleiram) for his awesome [vagrant-symfony](https://github.com/kleiram/vagrant-symfony).

