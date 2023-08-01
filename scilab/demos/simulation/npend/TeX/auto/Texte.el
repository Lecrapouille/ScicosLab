(TeX-add-style-hook
 "Texte"
 (lambda ()
   (TeX-add-to-alist 'LaTeX-provided-class-options
                     '(("article" "11pt")))
   (TeX-run-style-hooks
    "latex2e"
    "npend"
    "article"
    "art11")
   (TeX-add-symbols
    "tenrm"
    "elvrm"
    "sixrm"
    "sevrm"
    "dotx"
    "doty"
    "dotq"
    "dotth"
    "derivt"
    "derp")
   (LaTeX-add-labels
    "const1"
    "const"
    "eqp")))

