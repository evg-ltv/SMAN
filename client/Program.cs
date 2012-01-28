using System;

namespace Sman
{
    static class Program
    {
        static void Main(string[] args)
        {
            SmanParameters Params = new SmanParameters(args);
            try
            {
                ProceedCommand(Params);
            }
            catch (Exception e)
            {
                SmanMessage.RaiseError(e.Message);
            }
        }

        static void ProceedCommand(SmanParameters Params)
        {
            if (Params.Command == SmanConstants.cmdCRC)
            {
                SmanConfigFile.CreateNewConfigFile();
            }
            else if (Params.Command == SmanConstants.cmdADD)
            {
                SmanConfigFile.AddNewConfigFileEntity();
            }
            else if (Params.Command == SmanConstants.cmdHELP)
            {
                SmanIO.ShowHelp();
            }
            else if (Params.Command == SmanConstants.cmdVER)
            {
                SmanIO.ShowVersion();
            }
            else if (Params.Command == SmanConstants.cmdDS)
            {
                SmanOracle.Connect(Params.Alias);
                Console.WriteLine(SmanOracle.GetDropScript(Params));
                SmanOracle.Disconnect();
            }
            else
            {
                SmanOracle.Connect(Params.Alias);
                SmanTiming.Process();
                if (Params.Command == SmanConstants.cmdLC)
                {
                    Console.WriteLine(SmanOracle.GetComponents());
                }
                else if (Params.Command == SmanConstants.cmdCD)
                {
                    Console.WriteLine(SmanOracle.GetComponentDetails(Params));
                }
                else if (Params.Command == SmanConstants.cmdLL)
                {
                    Console.WriteLine(SmanOracle.GetLabels(Params));
                }
                else if (Params.Command == SmanConstants.cmdLD)
                {
                    Console.WriteLine(SmanOracle.GetLabelDetails(Params));
                }
                else if (Params.Command == SmanConstants.cmdS)
                {
                    SmanOracle.SaveObjects(Params);
                }
                else if (Params.Command == SmanConstants.cmdG)
                {
                    SmanIO.SaveFiles(SmanOracle.GetObjects(Params));
                }
                else if (Params.Command == SmanConstants.cmdSG)
                {
                    SmanOracle.SaveObjects(Params);
                    SmanIO.SaveFiles(SmanOracle.GetObjects(Params));
                }
                else if (Params.Command == SmanConstants.cmdGO)
                {
                    SmanOracle.SaveSingleObject(Params);
                    SmanIO.SaveFiles(SmanOracle.GetObjects(Params));
                }
                else if (Params.Command == SmanConstants.cmdFD)
                {
                    SmanIO.SaveFiles(SmanOracle.GetFullDeploy(Params));
                }
                else if (Params.Command == SmanConstants.cmdDD)
                {
                    SmanIO.SaveFiles(SmanOracle.GetDiffDeploy(Params));
                }
                SmanTiming.Process();
                SmanOracle.Disconnect();
            }
        }
    }

    class SmanParameters
    {
        public string Command;
        public string Alias;
        public string Component;
        public string Label;
        public string Object;
        public string DeployName;
        public string FromLabel;
        public string ToLabel;

        public SmanParameters(string[] args)
        {
            if (args.Length == 0)
            {
                Command = SmanConstants.cmdHELP;
            }
            else
            {
                Command = args[0];
            }
            try
            {
                if (Command == SmanConstants.cmdCRC  || Command == SmanConstants.cmdADD || 
                    Command == SmanConstants.cmdHELP || Command == SmanConstants.cmdVER)
                {
                    //No arguments for these commands
                }
                else if (Command == SmanConstants.cmdLC)
                {
                    Alias = args[1];
                }
                else if (Command == SmanConstants.cmdCD || Command == SmanConstants.cmdLL || Command == SmanConstants.cmdDS)
                {
                    Alias = args[1];
                    Component = args[2];
                }
                else if (Command == SmanConstants.cmdLD || Command == SmanConstants.cmdG)
                {
                    Alias = args[1];
                    Label = args[2];
                }
                else if (Command == SmanConstants.cmdS || Command == SmanConstants.cmdSG)
                {
                    Alias = args[1];
                    Component = args[2];
                    Label = args[3];
                }
                else if (Command == SmanConstants.cmdGO)
                {
                    Alias = args[1];
                    Component = args[2];
                    Label = args[3];
                    Object = args[4];
                }
                else if (Command == SmanConstants.cmdFD)
                {
                    Alias = args[1];
                    Label = args[2];
                    DeployName = args[3];
                }
                else if (Command == SmanConstants.cmdDD)
                {
                    Alias = args[1];
                    FromLabel = args[2];
                    ToLabel = args[3];
                    Label = args[4];
                    DeployName = args[5];
                }
                else
                {
                    SmanMessage.RaiseError(string.Format(SmanConstants.msgUnknownParameter, Command));
                }
            }
            catch (IndexOutOfRangeException)
            {
                SmanMessage.RaiseError(SmanConstants.msgNotEnoughParameters);
            }
        }
    }
}
