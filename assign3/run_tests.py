"""
Simple testrunner for students
"""
import subprocess
import json
import sys
import difflib

if sys.version_info < (3, 3):
    raise Exception("This script should be run using a newer version of Python 3.")

with open("assign_config.json") as config_f:
    config = json.load(config_f)

usage = """CS242 Student Testing Harness
How to read results:

For failing tests, a diff will be printed. Identical lines have no leading 
symbol. Other lines have a (-) to indicate your result, and (+) to indicate
the solution result.

Remember that for errors, you only need to also pass back an error. We do
not check the exact text of error messages.


Example Passing Test:
Test foo passed


Example Failing Test:
Test foo failed:
Test command `./foo_test`
========================================
+ A line of the Correct Result
- Your Result
  Matching line in the result
========================================
"""

print(usage)
print()
print("Test Results:")
print("=" * 40)

differ = difflib.Differ()
userExec = "./user.sh "
solExec = "./solution.sh "
sol = ""
result = ""

try:
    exec_make = subprocess.check_output("make > /dev/null", timeout=300, stderr=subprocess.STDOUT, shell=True)
    make_res = exec_make.decode("utf-8")
except Exception as e:
    result = "Python Exception " + str(e)
if result == "":
    print("Test", "Make", "passed")
else:
    print("Test", "Make", "failed:")
    print(result)
    exit(-1)

for test in config["tests"]:
    try:
        PIPE = subprocess.PIPE
        timeout = test["timeout"] if "timeout" in test else 10
        exec_res = subprocess.check_output(userExec + test["command"], timeout=timeout, stderr=subprocess.STDOUT, shell=True)
        exec_sol = subprocess.check_output(solExec + test["command"], timeout=timeout, stderr=subprocess.STDOUT, shell=True)
        sol = exec_sol.decode("utf-8")
        result = exec_res.decode("utf-8")
    except Exception as e:
        result = "Python Exception " + str(e)
    
    if "Error:" in result and "Error:" in sol:
        print("Test", test["name"], "passed")
    elif result == sol:
        print("Test", test["name"], "passed")
    else:
        print("Test", test["name"], "failed:")
        print("Test command `", test["command"], "`", sep="")
        print("=" * 40)
        print("".join(differ.compare(result.splitlines(True), sol.splitlines(True))))
        print("=" * 40)
