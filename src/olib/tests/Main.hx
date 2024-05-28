package olib.tests;

import utest.Runner;
import utest.ui.Report;
import olib.logging.Logger.LoggerTest;

class Main
{
    public static function main()
    {
        var runner = new Runner();
        runner.addCase(new LoggerTest());
        Report.create(runner);
        runner.run();
    }
}
