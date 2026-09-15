#!/usr/bin/env zsh

if (( $+commands[java] )); then
  # export JAVA_TOOL_OPTIONS="-Djava.util.prefs.userRoot=$XDG_DATA_HOME/java -Djavafx.cachedir=$XDG_CACHE_HOME/openjfx"
  export GRADLE_USER_HOME=$XDG_DATA_HOME/gradle
fi

if (( $+commands[mvn] )); then
  export MAVEN_ARGS="--settings $XDG_CONFIG_HOME/maven/settings.xml"
  export MAVEN_OPTS="-Dmaven.repo.local=$XDG_CACHE_HOME/maven/repository"
fi


