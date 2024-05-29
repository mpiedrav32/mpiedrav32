(setq-default make-backup-files nil
              auto-save-default nil
              inhibit-startup-message 1
              initial-scratch-message nil
              display-time-24hr-format 1
              display-time-default-load-average nil
              display-time-day-and-date 1
              tab-always-indent 'complete
              c-basic-offset 4
              c-default-style "k&r"
              indent-tabs-mode nil)

(when (display-graphic-p)
  (set-face-font 'default "Noto Sans Mono 12")
  (scroll-bar-mode -1)
  (tool-bar-mode -1))

(menu-bar-mode -1)
(savehist-mode 1)
(display-time-mode 1)
(display-battery-mode 1)
(show-paren-mode 1)
(line-number-mode 1)
(column-number-mode 1)
