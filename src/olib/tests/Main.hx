package olib.tests;

import utest.Runner;
import utest.ui.Report;
import olib.tests.LoggerTest;
import olib.tests.MessageTest;

class Main
{
    public static function main()
    {
        var runner = new Runner();
        runner.addCase(new LoggerTest());
        runner.addCase(new MessageTest());
        Report.create(runner);
        runner.run();
    }
}
