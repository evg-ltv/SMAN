using System;
using System.Collections.Generic;
using Oracle.DataAccess.Client;
using Oracle.DataAccess.Types;

namespace Sman
{
    class SmanObject
    {
        public string Path;
        public string FileName;
        public string Data;

        public SmanObject(string path, string fileName, string data)
        {
            this.Path = path;
            this.FileName = fileName;
            this.Data = data;
        }
    }

    static class SmanOracle
    {
        static OracleConnection SmanOraCon;

        public static void Connect(string Alias)
        {
            SmanOraCon = new OracleConnection();
            SmanOraCon.ConnectionString = SmanOracleUtils.GetConnectionString(Alias);
            try
            {
                SmanOraCon.Open();
            }
            catch(Exception e)
            {
                SmanMessage.RaiseError(e.Message);
            }
            CheckPackageExistence();
            SmanUtils.CheckCompatibility();
        }

        public static void Disconnect()
        {
            SmanOraCon.Close();
            SmanOraCon.Dispose();
        }

        static void CheckPackageExistence()
        {
            OracleCommand Command = new OracleCommand(SmanConstants.sqlDummy, SmanOraCon);
            try
            {
                Command.ExecuteNonQuery();
            }
            catch
            {
                SmanMessage.RaiseError(SmanConstants.msgSmanNotFound);
            }
        }

        public static string GetVersion()
        {
            OracleCommand Command = new OracleCommand(SmanConstants.sqlGetVersion, SmanOraCon);
            SmanOracleUtils.AddOutVariable(Command, OracleDbType.Clob);
            try
            {
                Command.ExecuteNonQuery();
            }
            catch
            {
                return SmanConstants.unknown;
            }
            return ((OracleClob)Command.Parameters[0].Value).Value;
        }

        public static string GetComponents()
        {
            OracleCommand Command = new OracleCommand(SmanConstants.sqlGetComponents, SmanOraCon);
            SmanOracleUtils.AddOutVariable(Command, OracleDbType.Clob);
            try
            {
                Command.ExecuteNonQuery();
            }
            catch (Exception e)
            {
                SmanMessage.RaiseError(SmanOracleUtils.GetOracleUserError(e.Message));
            }
            return ((OracleClob)Command.Parameters[0].Value).Value;
        }

        public static string GetComponentDetails(SmanParameters Params)
        {
            OracleCommand Command = new OracleCommand(SmanConstants.sqlGetComponentDetails, SmanOraCon);
            SmanOracleUtils.AddOutVariable(Command, OracleDbType.Clob);
            SmanOracleUtils.AddInVariable(Command, OracleDbType.Varchar2, Params.Component);
            try
            {
                Command.ExecuteNonQuery();
            }
            catch (Exception e)
            {
                SmanMessage.RaiseError(SmanOracleUtils.GetOracleUserError(e.Message));
            }
            return ((OracleClob)Command.Parameters[0].Value).Value;
        }

        public static string GetLabels(SmanParameters Params)
        {
            OracleCommand Command = new OracleCommand(SmanConstants.sqlGetComponentLabels, SmanOraCon);
            SmanOracleUtils.AddOutVariable(Command, OracleDbType.Clob);
            SmanOracleUtils.AddInVariable(Command, OracleDbType.Varchar2, Params.Component);
            try
            {
                Command.ExecuteNonQuery();
            }
            catch (Exception e)
            {
                SmanMessage.RaiseError(SmanOracleUtils.GetOracleUserError(e.Message));
            }
            return ((OracleClob)Command.Parameters[0].Value).Value;
        }

        public static string GetLabelDetails(SmanParameters Params)
        {
            OracleCommand Command = new OracleCommand(SmanConstants.sqlGetLabelDetails, SmanOraCon);
            SmanOracleUtils.AddOutVariable(Command, OracleDbType.Clob);
            SmanOracleUtils.AddInVariable(Command, OracleDbType.Varchar2, Params.Label);
            try
            {
                Command.ExecuteNonQuery();
            }
            catch (Exception e)
            {
                SmanMessage.RaiseError(SmanOracleUtils.GetOracleUserError(e.Message));
            }
            return ((OracleClob)Command.Parameters[0].Value).Value;
        }

        public static void SaveObjects(SmanParameters Params)
        {
            OracleCommand Command = new OracleCommand(SmanConstants.sqlSaveObjects, SmanOraCon);
            SmanOracleUtils.AddInVariable(Command, OracleDbType.Varchar2, Params.Component);
            SmanOracleUtils.AddInVariable(Command, OracleDbType.Varchar2, Params.Label);
            try
            {
                Command.ExecuteNonQuery();
            }
            catch (Exception e)
            {
                SmanMessage.RaiseError(SmanOracleUtils.GetOracleUserError(e.Message));
            }
        }

        public static void SaveSingleObject(SmanParameters Params)
        {
            OracleCommand Command = new OracleCommand(SmanConstants.sqlSaveSingleObject, SmanOraCon);
            SmanOracleUtils.AddInVariable(Command, OracleDbType.Varchar2, Params.Component);
            SmanOracleUtils.AddInVariable(Command, OracleDbType.Varchar2, Params.Label);
            SmanOracleUtils.AddInVariable(Command, OracleDbType.Varchar2, Params.Object);
            try
            {
                Command.ExecuteNonQuery();
            }
            catch (Exception e)
            {
                SmanMessage.RaiseError(SmanOracleUtils.GetOracleUserError(e.Message));
            }
        }

        public static List<SmanObject> GetObjects(SmanParameters Params)
        {
            OracleCommand Command = new OracleCommand(SmanConstants.sqlGetObjects, SmanOraCon);
            SmanOracleUtils.AddInVariable(Command, OracleDbType.Varchar2, Params.Label);
            OracleDataReader DataReader = Command.ExecuteReader();
            List<SmanObject> SmanObjects = new List<SmanObject>();
            try
            {
                while (DataReader.Read())
                {
                    SmanObjects.Add(new SmanObject(DataReader.GetString(0), DataReader.GetString(1), DataReader.GetString(2)));
                }
            }
            catch (Exception e)
            {
                SmanMessage.RaiseError(SmanOracleUtils.GetOracleUserError(e.Message));
            }
            DataReader.Dispose();
            return SmanObjects;
        }

        public static List<SmanObject> GetFullDeploy(SmanParameters Params)
        {
            OracleCommand Command = new OracleCommand(SmanConstants.sqlGetFullDeploy, SmanOraCon);
            SmanOracleUtils.AddInVariable(Command, OracleDbType.Varchar2, Params.Label);
            SmanOracleUtils.AddInVariable(Command, OracleDbType.Varchar2, Params.DeployName);
            OracleDataReader DataReader = Command.ExecuteReader();
            List<SmanObject> SmanObjects = new List<SmanObject>();
            try
            {
                while (DataReader.Read())
                {
                    SmanObjects.Add(new SmanObject(DataReader.GetString(0), DataReader.GetString(1), DataReader.GetString(2)));
                }
            }
            catch (Exception e)
            {
                SmanMessage.RaiseError(SmanOracleUtils.GetOracleUserError(e.Message));
            }
            DataReader.Dispose();
            return SmanObjects;
        }

        public static List<SmanObject> GetDiffDeploy(SmanParameters Params)
        {
            OracleCommand Command = new OracleCommand(SmanConstants.sqlGetDiffDeploy, SmanOraCon);
            SmanOracleUtils.AddInVariable(Command, OracleDbType.Varchar2, Params.FromLabel);
            SmanOracleUtils.AddInVariable(Command, OracleDbType.Varchar2, Params.ToLabel);
            SmanOracleUtils.AddInVariable(Command, OracleDbType.Varchar2, Params.Label);
            SmanOracleUtils.AddInVariable(Command, OracleDbType.Varchar2, Params.DeployName);
            OracleDataReader DataReader = Command.ExecuteReader();
            List<SmanObject> SmanObjects = new List<SmanObject>();
            try
            {
                while (DataReader.Read())
                {
                    SmanObjects.Add(new SmanObject(DataReader.GetString(0), DataReader.GetString(1), DataReader.GetString(2)));
                }
            }
            catch (Exception e)
            {
                SmanMessage.RaiseError(SmanOracleUtils.GetOracleUserError(e.Message));
            }
            DataReader.Dispose();
            return SmanObjects;
        }

        public static string GetDropScript(SmanParameters Params)
        {
            OracleCommand Command = new OracleCommand(SmanConstants.sqlGetDropScript, SmanOraCon);
            SmanOracleUtils.AddOutVariable(Command, OracleDbType.Clob);
            SmanOracleUtils.AddInVariable(Command, OracleDbType.Varchar2, Params.Component);
            try
            {
                Command.ExecuteNonQuery();
            }
            catch (Exception e)
            {
                SmanMessage.RaiseError(SmanOracleUtils.GetOracleUserError(e.Message));
            }
            return ((OracleClob)Command.Parameters[0].Value).Value;
        }
    }
}