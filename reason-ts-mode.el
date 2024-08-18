;;; reason-ts-mode.el --- F# Tree-Sitter Mode -*- lexical-binding: t; -*-

;; Copyright (C) 2024  Karan Ahlawat

;; Author: Karan Ahlawat <ahlawatkaran12@gmail.com>
;; Version: 1.0.0
;; Filename: reason.el
;; Package-Requires: ((emacs "29.1"))
;; Keywords: reason, languages, tree-sitter
;; URL: https://github.com/KaranAhlawat/reason-ts-mode

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;; This package provides a tree-sitter based major mode for the F#
;; programming language.  Currently, the supported features and their
;; statuses are
;; 1. font-locking (complete, looking for bugs and maintainance)
;; 2. imenu (basic support, needs work)
;; 3. indentation

;;; Code:

(require 'rx)
(require 'treesit)
(require 'thingatpt)

(declare-function treesit-parser-create "treesit.c")
(declare-function treesit-node-type "treesit.c")
(declare-function treesit-node-text "treesit.c")
(declare-function treesit-node-child-by-field-name "treesit.c")
(declare-function treesit-parent-while "treesit.c")
(declare-function treesit-parent-until "treesit.c")
(declare-function treesit-node-prev-sibling "treesit.c")
(declare-function treesit-node-next-sibling "treesit.c")
(declare-function treesit-node-type "treesit.c")
(declare-function treesit-node-text "treesit.c")
(declare-function treesit-node-start "treesit.c")
(declare-function treesit-node-end "treesit.c")
(declare-function treesit-node-child "treesit.c")

(defcustom reason-ts-indent-offset 2
  "Number of spaces for each indentation in `reason-ts-mode'."
  :version "29.1"
  :type 'integer
  :safe 'integerp
  :group 'reason-ts)

;; utility functions -- begin

(defun reason-ts--node-type= (type node)
  "Compare TYPE and type of NODE for string equality."
  (string= type (treesit-node-type node)))

;; utility functions -- end

;; FIX
(defvar reason-ts--syntax-table
  (let ((table (make-syntax-table)))

    ;; Operators
    (dolist (i '(?+ ?- ?* ?/ ?& ?| ?^ ?! ?< ?> ?~ ?@))
      (modify-syntax-entry i "." table))

    ;; Strings
    (modify-syntax-entry ?\" "\"" table)
    (modify-syntax-entry ?\\ "\\" table)
    (modify-syntax-entry ?\' "_"  table)

    ;; Comments
    (modify-syntax-entry ?/  ". 124b" table)
    (modify-syntax-entry ?*  ". 23n"  table)
    (modify-syntax-entry ?\n "> b"    table)
    (modify-syntax-entry ?\^m "> b"   table)

    table)
  "Syntax table in use in reason mode buffers.")

;; KEYWORDS AND LITERALS

;; FONT LOCK
(defvar reason-ts-font-lock-rules
  `( :language reason
     :feature variable
     ((value_name) @font-lock-variable-name-face)

     :language reason
     :feature module
     ([(module_name)
       (module_type_name)] @font-lock-type-face)))

;;; WIP
(defvar reason-ts--indent-rules
  `((reason
     ((node-is ,(rx ?=)) parent-bol reason-ts-indent-offset)
     (no-node parent 0))))

(defun reason-ts--defun-name (_)
  "Return the defun name of NODE.
Return nil if there is no name or if NODE is not a defun node."
  "Bazza")

;;;###autoload
(define-derived-mode reason-ts-mode prog-mode " Reason (TS)"
  "Major mode for ReasonML files using tree-sitter."
  :group 'reason-ts
  :syntax-table reason-ts--syntax-table

  (when (treesit-ready-p 'reason)
    (treesit-parser-create 'reason)

    ;; Comments
    (setq-local comment-start "// ")
    (setq-local comment-end "")
    (setq-local comment-start-skip (rx "//" (* (syntax whitespace))))

    (setq-local treesit-font-lock-settings (apply #'treesit-font-lock-rules reason-ts-font-lock-rules))
    (setq-local treesit-font-lock-feature-list '((comment keyword)
                                                 (type constant module)
                                                 (extra function variable)
                                                 (operator literal punctuation)))


    (setq-local treesit-simple-indent-rules reason-ts--indent-rules)

    ;; Navigation.
    (setq-local treesit-defun-name-function #'reason-ts--defun-name)

    ;; TODO (could possibly be more complex?)
    ;; (setq-local treesit-simple-imenu-settings
    ;;             `(("Class" "\\`class_definition\\'" nil nil)
    ;;               ("Trait" "\\`trait_definition\\'" nil nil)
    ;;               ("Enum" "\\`enum_definition\\'" nil nil)
    ;;               ("Object" "\\`object_definition\\'" nil nil)
    ;;               ("Function" "\\`function_definition\\'" nil nil)
    ;;               ("Definition" "\\`function_declaration'" nil nil)))

    (treesit-major-mode-setup)))

(provide 'reason-ts-mode)
;;; reason-ts-mode.el ends here
