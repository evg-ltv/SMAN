using System;
using System.Collections.Generic;
using System.Data;
using System.Diagnostics;
using System.IO;
using System.Reflection;
using System.Security.Cryptography;
using System.Text;
using Oracle.DataAccess.Client;

namespace Sman
{
    static class SmanSecurity
    {
        public static string EncryptPassword(string password)
        {
            UnicodeEncoding ByteConverter = new UnicodeEncoding();
            byte[] encryptedPassword = ProtectedData.Protect(ByteConverter.GetBytes(password), SmanConstants.ProtectionKey, DataProtectionScope.CurrentUser);
            return Convert.ToBase64String(encryptedPassword);
        }

        public static string DecryptPassword(string password)
        {
            UnicodeEncoding ByteConverter = new UnicodeEncoding();
            StringBuilder sb = new StringBuilder();
            byte[] encryptedPassword = Convert.FromBase64String(password);
            sb.Append(ByteConverter.GetChars(ProtectedData.Unprotect(encryptedPassword, SmanConstants.ProtectionKey, DataProtectionScope.CurrentUser)));
            return sb.ToString();
        }
    }

    static class SmanMessage
    {
        public static void RaiseError(string Error)
        {
            Console.WriteLine("Error: {0}", Error);
            Environment.Exit(-1);
        }
    }

    static class SmanIO
    {
        public static void ShowVersion()
        {
            Console.WriteLine(SmanConstants.msgVersion, SmanConstants.version);
        }

        public static void ShowHelp()
        {
            foreach (string Option in SmanConstants.commandLineOptions)
            {
                Console.WriteLine(Option);
            }
            Console.WriteLine();
            Console.WriteLine(SmanConstants.msgHelpInfo);
        }

        public static string GetPassword()
        {
            StringBuilder sb = new StringBuilder();
            ConsoleKeyInfo key;
            while (true)
            {
                key = Console.ReadKey(true);
                if (key.Key == ConsoleKey.Enter)
                {
                    break;
                }
                sb.Append(key.KeyChar);
                Console.Write("*");
            }
            Console.WriteLine();
            return sb.ToString();
        }

        public static void SaveFiles(List<SmanObject> SmanObjects)
        {
            DirectoryInfo LocalDir = new DirectoryInfo(".");
            string FileName = null;
            foreach (SmanObject SmanObject in SmanObjects)
            {
                if (SmanObject.Path != "/")
                {
                    LocalDir.CreateSubdirectory(SmanObject.Path);
                    FileName = SmanObject.Path + SmanObject.FileName;
                }
                else
                {
                    FileName = SmanObject.FileName;
                }
                File.WriteAllText(FileName, SmanObject.Data, Encoding.Default);
            }
        }
    }

    static class SmanTiming
    {
        private static Stopwatch sw;

        public static void Process()
        {
            if (SmanConstants.timing)
            {
                if (sw == null)
                {
                    sw = Stopwatch.StartNew();
                }
                else
                {
                    Console.WriteLine(SmanConstants.msgElapsedTime, sw.Elapsed);
                    sw = null;
                }
            }
        }
    }

    static class SmanUtils
    {
        public static string GetCurrentDirectory()
        {
            Assembly a = Assembly.GetEntryAssembly();
            return Path.GetDirectoryName(a.Location);
        }

        public static void CheckCompatibility()
        {
            string serverVersion = SmanOracle.GetVersion();
            int numericClientVersion = Convert.ToInt32(SmanConstants.version.Replace(".", null));
            int numericServerVersion = -1;
            if (serverVersion != SmanConstants.unknown)
            {
                numericServerVersion = Convert.ToInt32(serverVersion.Replace(".", null));
            }
            if (numericServerVersion < numericClientVersion)
            {
                SmanMessage.RaiseError(string.Format(SmanConstants.msgIncompatibleVersions, SmanConstants.version, serverVersion));
            }
        }
    }

    static class SmanOracleUtils
    {
        public static string GetConnectionString(string Alias)
        {
            SmanOraConfig OraCfg = new SmanOraConfig();
            try
            {
                OraCfg = SmanOraConfig.Deserialize(SmanConstants.configFileName);
            }
            catch
            {
                SmanMessage.RaiseError(SmanConstants.msgConfigFileError);
            }
            return OraCfg.GetConnectionString(Alias);
        }

        public static void AddInVariable(OracleCommand Command, OracleDbType VarType, string VarValue)
        {
            OracleParameter Variable = new OracleParameter();
            Variable.OracleDbType = VarType;
            Variable.Direction = ParameterDirection.Input;
            Variable.Value = VarValue;
            Command.Parameters.Add(Variable);
        }

        public static void AddOutVariable(OracleCommand Command, OracleDbType VarType)
        {
            OracleParameter Variable = new OracleParameter();
            Variable.OracleDbType = VarType;
            Variable.Direction = ParameterDirection.Output;
            Command.Parameters.Add(Variable);
        }

        public static string GetOracleUserError(string EMessage)
        {
            string Message = EMessage;
            string oraUserErrorCode = SmanConstants.oraUserErrorCode + ": ";
            if (Message.IndexOf(oraUserErrorCode) != -1)
            {
                Message = Message.Replace(oraUserErrorCode, "");
                Message = Message.Substring(0, Message.IndexOf("\n"));
            }
            return Message;
        }
    }
}