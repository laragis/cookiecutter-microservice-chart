#!/usr/bin/env python
import os
import shutil

TERMINATOR = "\x1b[0m"
WARNING = "\x1b[1;33m [WARNING]: "
INFO = "\x1b[1;33m [INFO]: "
HINT = "\x1b[3;33m"
SUCCESS = "\x1b[1;32m [SUCCESS]: "

DEBUG_VALUE = "debug"


def remove_hpa_files():
  os.remove(os.path.join("templates", "hpa.yaml"))


def remove_vpa_files():
  os.remove(os.path.join("templates", "vpa.yaml"))


def remove_cache_files():
  os.remove(os.path.join("templates", "secret-redis.yaml"))


def remove_db_files():
  os.remove(os.path.join("templates", "secret-database.yaml"))


def remove_workload_files(type):
  workloads = ['deployment', 'statefulset', 'daemonset']
  filtered = list(filter(lambda x: x != type, workloads))
  file_names = [f"{workload}.yaml" for workload in filtered]

  for file_name in file_names:
    os.remove(os.path.join("templates", file_name))


def main():
  debug = "{{ cookiecutter.debug }}".lower() == "true"

  # Autoscaling
  if "{{ cookiecutter.use_autoscaling }}" == "hpa":
    remove_vpa_files()

  if "{{ cookiecutter.use_autoscaling }}" == "vpa":
    remove_hpa_files()

  if "{{ cookiecutter.use_autoscaling }}" == "none":
    remove_hpa_files()
    remove_vpa_files()

  # Workload
  remove_workload_files("{{ cookiecutter.use_workload }}")

  # Redis
  if "{{ cookiecutter.use_cache }}" == "False":
    remove_cache_files()

  # Database
  if "{{ cookiecutter.use_db }}" == "none":
    remove_db_files()


if __name__ == "__main__":
  main()
