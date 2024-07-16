if [ -z "$UID" ]; then
  readonly UID=$(id -u)
fi

if [ -z "$GID" ]; then
  readonly GID=$(id -g)
fi

export UID
export GID
