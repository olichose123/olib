package olib.tests;

import utest.Runner;
import utest.ui.Report;
import olib.logging.Logger.LoggerTest;
import olib.ecs.ECSTest;

class Main
{
    public static function main()
    {
        var runner = new Runner();
        runner.addCase(new LoggerTest());
        runner.addCase(new ECSTest());
        Report.create(runner);
        runner.run();
    }
}
