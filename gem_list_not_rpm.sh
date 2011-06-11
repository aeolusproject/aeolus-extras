#!/bin/bash

GEMLIST=$(gem list -l --no-versions)

for gem in $GEMLIST; do
    RUBYVER=$(rpm -q ruby-$gem --qf '%{VERSION}\n')
    if [ $? -eq 0 ]; then
	echo "ruby-$gem is RPM installed with version $RUBYVER"
	continue
    fi
    RUBYGEMVER=$(rpm -q rubygem-$gem --qf '%{VERSION}\n')
    if [ $? -eq 0 ]; then
	echo "rubygem-$gem is RPM installed with version $RUBYGEMVER"
	continue
    fi

    echo "ruby gem $gem is NOT RPM installed"
done
