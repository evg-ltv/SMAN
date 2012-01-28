using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Xml.Serialization;

namespace Sman
{
    public class SmanOraConfigEntity
    {
        public string Alias;
        public string UserName;
        public string Password;
        public string DataBase;

        public SmanOraConfigEntity() { }

        public SmanOraConfigEntity(string alias, string userName, string password, string dataBase)
        {
            this.Alias = alias;
            this.UserName = userName;
            this.Password = password;
            this.DataBase = dataBase;
        }
    }

    [Serializable]
    public class SmanOraConfig
    {
        public List<SmanOraConfigEntity> SmanOraConfigEntities;

        public SmanOraConfig()
        {
            SmanOraConfigEntities = new List<SmanOraConfigEntity>();
        }

        private bool IfAliasExists(string Alias)
        {
            int entityCount = (from i in SmanOraConfigEntities where i.Alias == Alias select i).Count();
            if (entityCount > 0)
                return true;
            else
                return false;
        }

        public void Add(string Alias, string UserName, string Password, string DataBase)
        {
            if (IfAliasExists(Alias))
            {
                SmanMessage.RaiseError(SmanConstants.msgExistingAlias);
            }
            else
            {
                SmanOraConfigEntities.Add(new SmanOraConfigEntity(Alias, UserName, Password, DataBase));
            }
        }

        public string GetConnectionString(string Alias)
        {
            if (!IfAliasExists(Alias))
            {
                SmanMessage.RaiseError(string.Format(SmanConstants.msgUnknownAlias, Alias));
            }
            foreach (SmanOraConfigEntity Entity in SmanOraConfigEntities)
            {
                if (Entity.Alias == Alias)
                {
                    return string.Format(SmanConstants.oraConnectionString, Entity.UserName, Entity.Password, Entity.DataBase);
                }
            }
            return null;
        }

        //Encrypts every password in the list
        public void Encrypt()
        {
            foreach (SmanOraConfigEntity Entity in SmanOraConfigEntities)
            {
                if (Entity.Password != null)
                {
                    Entity.Password = SmanSecurity.EncryptPassword(Entity.Password);
                }
            }
        }

        //Decrypts every password in the list
        public void Decrypt()
        {
            foreach (SmanOraConfigEntity Entity in SmanOraConfigEntities)
            {
                if (Entity.Password != null)
                {
                    Entity.Password = SmanSecurity.DecryptPassword(Entity.Password);
                }
            }
        }

        public static void Serialize(string file, SmanOraConfig config)
        {
            config.Encrypt();
            XmlSerializer xs = new XmlSerializer(config.GetType());
            StreamWriter writer = File.CreateText(file);
            xs.Serialize(writer, config);
            writer.Flush();
            writer.Close();
        }

        public static SmanOraConfig Deserialize(string file)
        {
            XmlSerializer xs = new XmlSerializer(typeof(SmanOraConfig));
            StreamReader reader = File.OpenText(file);
            SmanOraConfig config = (SmanOraConfig)xs.Deserialize(reader);
            reader.Close();
            config.Decrypt();
            return config;
        }
    }

    public static class SmanConfigFile
    {
        private static void GetSmanOraCfgParameters(out string Alias, out string UserName, out string Password, out string DataBase)
        {
            Console.Write(SmanConstants.msgInputAlias);
            Alias = Console.ReadLine();
            Console.Write(SmanConstants.msgInputUser);
            UserName = Console.ReadLine();
            Console.Write(SmanConstants.msgInputPass);
            Password = SmanIO.GetPassword();
            Console.Write(SmanConstants.msgInputDB);
            DataBase = Console.ReadLine();
        }

        public static void CreateNewConfigFile()
        {
            SmanOraConfig OraCfg = new SmanOraConfig();
            string Alias, UserName, Password, DataBase;
            GetSmanOraCfgParameters(out Alias, out UserName, out Password, out DataBase);
            OraCfg.Add(Alias, UserName, Password, DataBase);
            SmanOraConfig.Serialize(SmanConstants.configFileName, OraCfg);
        }

        public static void AddNewConfigFileEntity()
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
            string Alias, UserName, Password, DataBase;
            GetSmanOraCfgParameters(out Alias, out UserName, out Password, out DataBase);
            OraCfg.Add(Alias, UserName, Password, DataBase);
            SmanOraConfig.Serialize(SmanConstants.configFileName, OraCfg);
        }
    }
}