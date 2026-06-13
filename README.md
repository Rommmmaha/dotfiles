# 🐧 Arch Linux dotfiles

## 📝 User Config

<details>
<summary>Install chezmoi</summary>

  ```sh
  sudo pacman -Syu chezmoi
  ```
</details>

<details>
<summary>Apply chezmoi</summary>

  ```sh
  chezmoi init --apply https://github.com/Rommmmaha/dotfiles.git
  ```
</details>

## 📦 Install Packages

<details>
<summary>Install yay</summary>

  ```sh
  sudo pacman -Syu --needed git base-devel
  git clone https://aur.archlinux.org/yay-bin.git
  cd yay-bin
  makepkg -si
  ```
</details>

<details>
<summary>Install required packages</summary>

  ```sh
  yay -Sy --needed - $(cat ~/.local/share/chezmoi/packages.txt)
  ```
</details>

## ⚙️ System Config (Manual)

<details>
<summary>FUSE Configuration</summary>

**File:** `/etc/fuse.conf`

```conf
user_allow_other
```
</details>

<details>
<summary>DNS Configuration</summary>

**File:** `/etc/NetworkManager/NetworkManager.conf`

```conf
[main]
dns=dnsmasq
```

**File:** `/etc/NetworkManager/dnsmasq.d/dns.conf`

```conf
server=1.1.1.1
server=1.0.0.1
```
</details>

<details>
<summary>Remove sudo retry delay</summary>

**File:** `/etc/security/faillock.conf`

```conf
unlock_time = 1
```

**File:** `/etc/pam.d/system-auth`

*Add `nodelay` to the following lines:*

```conf
auth required                pam_faillock.so preauth
auth [success=1 default=bad] pam_unix.so     try_first_pass nullok
auth [default=die]           pam_faillock.so authfail
```
</details>

<details>
<summary>Locale Formatting (English UI, UA Formats)</summary>

**File:** `/etc/locale.gen`

```conf
en_US.UTF-8 UTF-8
en_GB.UTF-8 UTF-8
uk_UA.UTF-8 UTF-8
```

**File:** `/etc/locale.conf`

```conf
LANG=en_US.UTF-8
LC_COLLATE=en_US.UTF-8
LC_TIME=en_GB.UTF-8
LC_ADDRESS=uk_UA.UTF-8
LC_IDENTIFICATION=uk_UA.UTF-8
LC_MEASUREMENT=uk_UA.UTF-8
LC_MONETARY=uk_UA.UTF-8
LC_NAME=uk_UA.UTF-8
LC_NUMERIC=uk_UA.UTF-8
LC_PAPER=uk_UA.UTF-8
LC_TELEPHONE=uk_UA.UTF-8
```

*Run after editing:*

```sh
sudo locale-gen
```
</details>

<details>
<summary>Enable Numlock on boot</summary>

**File:** `/etc/mkinitcpio.conf`

*Add `sd-numlock` before `block`.*

*Run after editing:*

```sh
sudo mkinitcpio -P
```
</details>

<details>
<summary>Autologin</summary>

**File:** `/etc/systemd/system/getty@tty1.service.d/autologin.conf`

```sh
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin YOUR_USERNAME --noclear %I $TERM
```
</details>