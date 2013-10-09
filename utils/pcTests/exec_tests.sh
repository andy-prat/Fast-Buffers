#!/bin/bash
# This scripts run the unit tests. Supports two optional parameters.
# @param The unit test to be run. If it isn't set, then all unit tests are run.
# @param Second parameter is the used architecture. Supported i86 and x64. If it isn't set all architectures are used.

errorstatus=0
test_selected=""
# @default, all targets are used (i86 and x64)
test_targets=""

# This function execute a test in a directory.
# @param Name/Directory of the test
function execTest
{
    # CDR unit test
    # Clean output directory
    rm -rf output/*
    # Info about test
    echo "EXECUTING $1 for $EPROSIMA_TARGET using CDR"
    # Generates the file with RPCDDS script
    ../../scripts/efastbuffers.sh -o output -ser cdr -example $EPROSIMA_TARGET "$1/$1.idl"
    errorstatus=$?
    if [ $errorstatus != 0 ]; then return; fi
    # Compile the generated library
    make -C output -f makefile_$EPROSIMA_TARGET all
    errorstatus=$?
    if [ $errorstatus != 0 ]; then return; fi
    # Copy static test files into output directory
    cp $1/* output/
    errorstatus=$?
    if [ $errorstatus != 0 ]; then return; fi
    # Compile again the generated library
    make -C output -f makefile_$EPROSIMA_TARGET all
    errorstatus=$?
    if [ $errorstatus != 0 ]; then return; fi
    # Compile the application test
    make -C output -f makefile_$1 all
    errorstatus=$?
    if [ $errorstatus != 0 ]; then return; fi
    # Execute the test application
    output/bin/$EPROSIMA_TARGET/$1Test
    errorstatus=$?
    if [ $errorstatus != 0 ]; then return; fi

    # FastCDR unit test
    # Clean output directory
    rm -rf output/*
    # Info about test
    echo "EXECUTING $1 for $EPROSIMA_TARGET using FastCDR"
    # Generates the file with RPCDDS script
    ../../scripts/efastbuffers.sh -o output -ser fastcdr -example $EPROSIMA_TARGET "$1/$1.idl"
    errorstatus=$?
    if [ $errorstatus != 0 ]; then return; fi
    # Compile the generated library
    make -C output -f makefile_$EPROSIMA_TARGET all
    errorstatus=$?
    if [ $errorstatus != 0 ]; then return; fi
    # Copy static test files into output directory
    cp $1/* output/
    errorstatus=$?
    if [ $errorstatus != 0 ]; then return; fi
    # Compile again the generated library
    make -C output -f makefile_$EPROSIMA_TARGET all
    errorstatus=$?
    if [ $errorstatus != 0 ]; then return; fi
    # Compile the application test
    make -C output -f makefile_$1 all
    errorstatus=$?
    if [ $errorstatus != 0 ]; then return; fi
    # Execute the test application
    output/bin/$EPROSIMA_TARGET/$1Test
    errorstatus=$?
    if [ $errorstatus != 0 ]; then return; fi
}

# Get the optional parameter
if [ $# -ge 1 ] && [ -n $1 ]; then
    if [ "$1" == "i86" ] || [ "$1" == "x64" ]; then
        test_targets=$1
    else
        test_selected=$1

        if [ $# -ge 2 ] && [ -n $2 ]; then
            if [ "$2" == "i86" ] || [ "$2" == "x64" ]; then
                test_targets=$2
            else
                echo Error: Bad argument in second parameter. Valid values: i86, x64
                exit -1;
            fi
        fi
    fi
fi

# Create symbolic link to EPROSIMADIR in the CDR folder.
if [ ! -e "../../../CDR/include/eProsima_cpp" ]; then
    ln -s $EPROSIMADIR/code/eProsima_cpp ../../../CDR/include/eProsima_cpp
    errorstatus=$?
    if [ $errorstatus != 0 ]; then return; fi
fi

# Create symbolic link to CDR include directory in FastBuffers folder.
if [ ! -e "../../include" ]; then
    ln -s ../CDR/include ../../include
    errorstatus=$?
    if [ $errorstatus != 0 ]; then return; fi
fi

# Create symbolic link to CDR library directory in FastBuffers folder.
if [ ! -e "../../lib" ]; then
    ln -s ../CDR/lib ../../lib
    errorstatus=$?
    if [ $errorstatus != 0 ]; then return; fi
fi

# Create output directory 
if [ ! -d "output" ]; then
    mkdir output
fi

# This script runs all tests in this directory and checks their results.
for dir in $(find . -mindepth 1 -maxdepth 1 -path ./output -prune -o -path ./.svn -prune -o -type d -printf "%f\n"); do
    if [ "$test_selected" == "" ] || [ "$test_selected" == "$dir" ]; then
        if [ -e "$dir/exec_test.sh" ] ; then
            if [ $errorstatus == 0 ]; then
                if [ -z $test_targets ] || [ "$test_targets" == "i86" ]; then
                    . $EPROSIMADIR/scripts/common_exectest_functions.sh setTarget i86
                    . $EPROSIMADIR/scripts/common_exectest_functions.sh setTargetLibraryPath ../../../lib/$EPROSIMA_TARGET
                    $dir/exec_test.sh
                    errorstatus=$?
                    . $EPROSIMADIR/scripts/common_exectest_functions.sh restoreTargetLibraryPath
                    . $EPROSIMADIR/scripts/common_exectest_functions.sh restoreTarget
                fi
            fi
            # x64 target
            if [ $errorstatus == 0 ]; then
                if [ -z $test_targets ] || [ "$test_targets" == "x64" ]; then
                    . $EPROSIMADIR/scripts/common_exectest_functions.sh setTarget x64
                    . $EPROSIMADIR/scripts/common_exectest_functions.sh setTargetLibraryPath ../../../lib/$EPROSIMA_TARGET
                    $dir/exec_test.sh
                    errorstatus=$?
                    . $EPROSIMADIR/scripts/common_exectest_functions.sh restoreTargetLibraryPath
                    . $EPROSIMADIR/scripts/common_exectest_functions.sh restoreTarget
                fi
            fi
        else
            # i86 target
            if [ $errorstatus == 0 ]; then
                if [ -z $test_targets ] || [ "$test_targets" == "i86" ]; then
                    . $EPROSIMADIR/scripts/common_exectest_functions.sh setTarget i86
                    . $EPROSIMADIR/scripts/common_exectest_functions.sh setTargetLibraryPath ../../../lib/$EPROSIMA_TARGET
                    execTest $dir
                    . $EPROSIMADIR/scripts/common_exectest_functions.sh restoreTargetLibraryPath
                    . $EPROSIMADIR/scripts/common_exectest_functions.sh restoreTarget
                fi
            fi
            # x64 target
            if [ $errorstatus == 0 ]; then
                if [ -z $test_targets ] || [ "$test_targets" == "x64" ]; then
                    . $EPROSIMADIR/scripts/common_exectest_functions.sh setTarget x64
                    . $EPROSIMADIR/scripts/common_exectest_functions.sh setTargetLibraryPath ../../../lib/$EPROSIMA_TARGET
                    execTest $dir
                    . $EPROSIMADIR/scripts/common_exectest_functions.sh restoreTargetLibraryPath
                    . $EPROSIMADIR/scripts/common_exectest_functions.sh restoreTarget
                fi
            fi
        fi
    fi

    # Detect error in call.
    if [ $errorstatus != 0 ]; then
        break
    fi
done

# Remove output directory
rm -r output

# Remove symbolic link from CDR library directory
if [ -e ../../lib ]; then
    rm ../../lib
fi

# Remove symbolic link from CDR include directory
if [ -e ../../include ]; then
    rm ../../include
fi

# Remove symbolic link from EPROSIMADIR
if [ -e ../../../CDR/include/eProsima_cpp ]; then
    rm ../../../CDR/include/eProsima_cpp
fi

if [ $errorstatus == 0 ]; then
    echo "TEST SUCCESSFULLY"
else
    echo "TEST FAILED"
fi

exit $errorstatus

