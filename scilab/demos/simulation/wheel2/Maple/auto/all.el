(TeX-add-style-hook
 "all"
 (lambda ()
   (TeX-add-to-alist 'LaTeX-provided-class-options
                     '(("article" "11pt")))
   (TeX-run-style-hooks
    "latex2"
    "wheel"
    "systeme"
    "article"
    "art11")
   (TeX-add-symbols
    "LL")))

