;;; eval-lines.el --- Evaluate lines in a buffer and insert output behind a marker

;; Copyright (C) 2011  Christian Johansen

;; Author: Christian Johansen <christian@cjohansen.no>

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; (require 'eval-lines)
;; (global-set-key (kbd "C-c C-e") 'eval-current-line)
;; (global-set-key (kbd "C-c M-e") 'eval-output-marked-lines)
;;
;; If you use rvm, ruby may not be available on your path. Do this:
;; (setq eval-ruby-interpreter "/home/christian/.rvm/rubies/ree-1.8.7-2010.02/bin/ruby")
;;

(defvar eval-output-marker "#=>"
  "Marker that specifies where output from eval'ing the
preceeding line goes. Defaults to '#=>', suitable for Ruby eval
output.")

(defvar eval-ruby-interpreter "ruby"
  "The Ruby interpreter to use.")

(make-local-variable 'eval-output-marker)

(defun eval-output-marked-lines ()
  "Evaluate all lines in the current buffer that includes
eval-output-marker and replace everything after the marker with
the output of eval'ing everything on the line before the marker."
  (interactive)
  (save-excursion
    (beginning-of-buffer)
    (while (goto-next-eval-output)
      (eval-current-line))))

(defun goto-next-eval-output ()
  "Puts point at the next eval output position."
  (interactive)
  (search-forward eval-output-marker nil t))

(defun eval-current-line ()
  "Evaluate the current line and insert the output behind the
eval marker."
  (interactive)
  (save-restriction
    (save-excursion
      (beginning-of-line)
      (insert "pp(")
      (goto-next-eval-output)
      (if (eolp) nil (kill-line))
      (insert " ")
      (narrow-to-region (point-min) (point))
      (let ((epos (point))
            (bpos (point-at-bol)))
        (goto-char (- (point) (length eval-output-marker) 1))
        (insert ")")
        (goto-char epos)
        (insert " ")
        (call-process eval-ruby-interpreter nil t t "-rpp" "-e" (buffer-substring (point-min) (point-max)))
        (goto-char bpos)
        (delete-region (point-marker) (+ (point-marker) 3)))
      (goto-next-eval-output)
      (goto-char (- (point) (length eval-output-marker) 1))
      (delete-char 1)
      (end-of-line)
      (kill-line))))

(provide 'eval-lines)
;;; eval-lines.el ends here
