## build版本号规则

用当前时间生成build版本号(要确保随时间增长,同时不要增长太快,版本号字串尽量短)：

1. 算出与2010.01.01之间的天数
2.每4个小时版本号加1 (每天最多产生6个版本)

elisp代码生成版本号与解析版本号:


```
;; 生成版本号
(defun vt-generate-version()
  (interactive)
  (let* ((d1 (time-to-days (encode-time 0 0 0 1 1 2010)))
         (d2  (time-to-days (current-time)))
         (days (- d2 d1))
         (hours (nth 2 (decode-time (current-time))))
         (res (+ (* days 6) (/ hours 4))))
    (message (format "version: %d" res))))

;; 解析出版本号对应的大概时间段
(defun vt-decode-version(number)
  (interactive "nversion:")
  (let* ((beginday (encode-time 0 0 0 1 1 2010))
         (days (/ number 6))
         (hours (* (% number 6) 4))
         (res1 (time-add beginday (days-to-time days)))
         (res2 (time-add res1 (seconds-to-time (* hours 3600)))))
    (message (format "time: %s" (format-time-string "%F %T"res2)))))

```

如: 2016-09-13 22:13:00 将生成版本号: 14687
