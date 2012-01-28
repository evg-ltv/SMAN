namespace Sman
{
    static class SmanConstants
    {
        //Version
        public const string version = "1.0.12";

        //Messages
        public const string msgExistingAlias = "Such an alias already exists";
        public const string msgUnknownAlias = "Unknown alias - {0}";
        public const string msgNotEnoughParameters = "Not enough parameters";
        public const string msgConfigFileError = "Config file hasn't been found (or has been corrupted). Create a new file using -crc option";
        public const string msgSmanNotFound = "There isn't SMAN on this schema";
        public const string msgUnknownParameter = "Unknown parameter - {0}";
        public const string msgVersion = "  Source Manager ver {0} (c) Litvinenko Evgeniy";
        public const string msgHelpInfo = "  SMAN uses ODP.Net to work with Oracle Databases. If you don't have it, reinstall Oracle Client and choose this component.";
        public const string msgIncompatibleVersions = " Client is incompatible with Server. Client version - {0}. Server version - {1}";
        public const string msgElapsedTime = "Elapsed Time: {0}";
        public const string msgInputAlias = "Input Alias: ";
        public const string msgInputUser = "Input Username: ";
        public const string msgInputPass = "Input Password: ";
        public const string msgInputDB = "Input DataBase: ";
        
        //Constants
        public const string oraConnectionString = "User Id={0};Password={1};Data Source={2}";
        public const string oraUserErrorCode = "ORA-20001";
        public static string configFileName = SmanUtils.GetCurrentDirectory() + "\\sman.xml";
        public const string unknown = "Unknown";

        //Parameters
        public const bool timing = true;

        //Password Protection Key
        public static byte[] ProtectionKey = { 0x00, 0x01, 0x00, 0x01, 0x00, 0x01, 0x00, 0x01, 0x00, 0x01, 0x00, 0x01, 0x00, 0x01, 0x00, 0x01 };
        
        //Oracle SQL queries & PL/SQL calls
        public const string sqlDummy = "BEGIN PKG_SMAN$.DUMMY; END;";
        public const string sqlGetVersion = "BEGIN :1 := PKG_SMAN$.GET_VERSION; END;";
        public const string sqlGetComponents = "BEGIN :1 := PKG_SMAN$.GET_COMPONENTS; END;";
        public const string sqlGetComponentDetails = "BEGIN :1 := PKG_SMAN$.GET_COMPONENT_DETAILS(:2); END;";
        public const string sqlGetComponentLabels = "BEGIN :1 := PKG_SMAN$.GET_COMPONENT_LABELS(:2); END;";
        public const string sqlGetLabelDetails = "BEGIN :1 := PKG_SMAN$.GET_LABEL_DETAILS(:2); END;";
        public const string sqlSaveObjects = "BEGIN PKG_SMAN$.SAVE_OBJECTS(:1, :2); END;";
        public const string sqlSaveSingleObject = "BEGIN PKG_SMAN$.SAVE_SINGLE_OBJECT(:1, :2, :3); END;";
        public const string sqlGetObjects = "SELECT * FROM TABLE(PKG_SMAN$.GET_OBJECTS(:1))";
        public const string sqlGetFullDeploy = "SELECT * FROM TABLE(PKG_SMAN$.GET_FULL_DEPLOY(:1, :2))";
        public const string sqlGetDiffDeploy = "SELECT * FROM TABLE(PKG_SMAN$.GET_DIFF_DEPLOY(:1, :2, :3, :4))";
        public const string sqlGetDropScript = "BEGIN :1 := PKG_SMAN$.GET_DROP_SCRIPT(:2); END;";
        
        //Command line options
        public const string cmdLC = "-lc";  //list of components
        public const string cmdCD = "-cd";  //components's details
        public const string cmdLL = "-ll";  //list of components' labels
        public const string cmdLD = "-ld";  //label's details
        public const string cmdS = "-s";    //save objects
        public const string cmdG = "-g";    //get saved objects
        public const string cmdSG = "-sg";  //save & get saved objects
        public const string cmdGO = "-go";  //get a single object
        public const string cmdFD = "-fd";  //get a full deploy
        public const string cmdDD = "-dd";  //get a differential deploy
        public const string cmdDS = "-ds";  //get a drop script
        public const string cmdCRC = "-crc";  //create a new config file
        public const string cmdADD = "-add";  //add a new alias to the config file
        public const string cmdHELP = "-help";  //this help
        public const string cmdVER = "-ver";  //version

        //Command line options - console output
        public static readonly string[] commandLineOptions = new string [] {
            "      -lc      list of components                   sman -lc <alias>",
            "      -cd      components's details                 sman -cd <alias> <component>",
            "      -ll      list of components' labels           sman -ll <alias> <component>",
            "      -ld      label's details                      sman -ld <alias> <label>",
            "      -s       save objects                         sman -s  <alias> <component> <label> / sman -s <alias> ALL <label>",
            "      -g       get saved objects                    sman -g  <alias> <label>",
            "      -sg      save & get saved objects             sman -sg <alias> <component> <label> / sman -sg <alias> ALL <label>",
            "      -go      get a single object                  sman -go <alias> <component> <label> <object>",
            "      -fd      get a full deploy                    sman -fd <alias> <label> <deploy name>",
            "      -dd      get a differential deploy            sman -dd <alias> <from label> <to label> <new label> <deploy name>",
            "      -ds      get a drop script                    sman -ds <alias> <component> / sman -ds <alias> ALL",
            "      -crc     create a new config file             sman -crc",
            "      -add     add a new alias to the config file   sman -add",
            "      -help    this help                            sman -help",
            "      -ver     version                              sman -ver"
        };
    }
}