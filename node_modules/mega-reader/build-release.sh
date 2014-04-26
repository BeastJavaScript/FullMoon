basedir=$(dirname $0)
cd $basedir

coffee -wc -o bin src/*.coffee &
coffee -wc test/test.coffee