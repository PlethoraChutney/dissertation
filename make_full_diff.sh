echo "===== Full Diff =====" > full-diff.txt
for filename in $(find . -name "*.qmd")
do
    echo \\n==============================\\n===== $filename =====\\n==============================\\n >> full-diff.txt
	git diff defense edits-first-draft -- $filename >> full-diff.txt
done

echo "===== DONE =====" >> full-diff.txt
