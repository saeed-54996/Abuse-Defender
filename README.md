# Abuse Defender

اسکریپت Abuse Defender،
یک اسکریپت امنیتی برای جلوگیری از سوءاستفاده‌های **NetScan** در سرورهای **Hetzner** است. این اسکریپت با دریافت لیست IPهای مخرب، آن‌ها را در فایروال‌های **UFW** و **iptables** مسدود می‌کند تا از اسکن شدن پورت‌های سرور شما توسط بات‌ها و مهاجمان جلوگیری شود.

## ویژگی‌ها
- دریافت خودکار لیست IPهای مهاجم از منبع معتبر
- اعمال قوانین امنیتی در **UFW** و **iptables**
- مسدود کردن ارتباط خروجی به IPهای مخرب و پورت‌های حساس
- امکان حذف سریع قوانین فایروال در صورت نیاز
- بررسی و نصب خودکار **UFW** و **iptables** در صورت عدم وجود
- ذخیره تنظیمات **iptables** برای اعمال مجدد پس از ریبوت سرور

## نصب و اجرا

برای اجرای مستقیم اسکریپت از طریق گیت‌هاب، کافیست دستور زیر را اجرا کنید:

```bash
bash <(curl -s https://raw.githubusercontent.com/saeed-54996/Abuse-Defender/main/abuse-defender.sh)
```

پس از اجرا، منویی نمایش داده می‌شود که می‌توانید یکی از گزینه‌های زیر را انتخاب کنید:

1. **نصب قوانین فایروال** (Install Firewall Rules) → این گزینه لیست IPهای بلاک‌شده را دریافت کرده و قوانین فایروال را اعمال می‌کند.
2. **حذف قوانین فایروال** (Remove Firewall Rules) → این گزینه تمامی قوانین اضافه شده را حذف می‌کند.
3. **خروج** (Exit) → بستن اسکریپت بدون انجام تغییرات.

## بررسی صحت اجرای قوانین فایروال

برای اطمینان از این که قوانین فایروال به درستی اعمال شده‌اند، می‌توانید از دستورات زیر استفاده کنید:

### بررسی قوانین **iptables**
```bash
sudo iptables -L -n --line-numbers
```

### بررسی قوانین **UFW**
```bash
sudo ufw status numbered
```

اگر لیست IPهای بلاک‌شده و پورت‌های محدود شده را مشاهده کردید، یعنی اسکریپت به درستی اجرا شده است. 🚀