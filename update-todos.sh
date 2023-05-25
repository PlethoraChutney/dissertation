rm todo.md
echo \# TODOs for $(date +%Y-%m-%d) > todo.md

for filename in $(find . -name "*.qmd")
do
    echo \\n\#\# $filename >> todo.md
    grep -on 'TODO:.*-->' $filename | sed 's/^/line /g' | sed 's/ -->$//g' | sed 's/TODO: //g' >> todo.md
done