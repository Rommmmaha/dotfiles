# My CachyOS dotfiles

## 🚀 1. Apply Config

```sh
chezmoi init --apply https://github.com/Rommmmaha/dotfiles.git
```

## 📦 2. Install Packages

```sh
yay -Sy $(cat ~/.local/share/chezmoi/packages.txt) --needed
```

## ⚙️ 3. System-Wide Config (Manual)

### FUSE Configuration

**File:** `/etc/fuse.conf`

```conf
user_allow_other
```

### DNS Configuration

**File:** `/etc/systemd/resolved.conf`

```conf
[Resolve]
DNS=1.1.1.1 1.0.0.1
FallbackDNS=8.8.8.8 9.9.9.9
Domains=~.
```

### Remove sudo retry delay

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

### Locale Formatting (English UI, UA Formats)

**File:** `/etc/locale.gen`

```conf
en_US.UTF-8 UTF-8
uk_UA.UTF-8 UTF-8
en_GB.UTF-8 UTF-8
```

**File:** `/etc/locale.conf`

```conf
LANG=en_GB.UTF-8
LC_ADDRESS=uk_UA.UTF-8
LC_IDENTIFICATION=uk_UA.UTF-8
LC_MEASUREMENT=uk_UA.UTF-8
LC_MONETARY=uk_UA.UTF-8
LC_NAME=uk_UA.UTF-8
LC_NUMERIC=uk_UA.UTF-8
LC_PAPER=uk_UA.UTF-8
LC_TELEPHONE=uk_UA.UTF-8
LC_TIME=en_GB.UTF-8
```

*Run after editing:*

```sh
sudo locale-gen
```

### Disable boot animation and enable Numlock

**File:** `/etc/mkinitcpio.conf`

1. Remove `plymouth` from HOOKS.
2. Add `numlock` before `block`.

*Run after editing:*

```sh
sudo mkinitcpio -P
```

### Autologin

**File:** `/etc/systemd/system/getty@tty1.service.d/autologin.conf`

```sh
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin YOUR_USERNAME --noclear %I $TERM
```
