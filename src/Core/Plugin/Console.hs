{-# LANGUAGE OverloadedStrings #-}
module Core.Plugin.Console where

import qualified Data.Text as Text
import           Data.List
import           Data.Foldable

import           System.Directory

import           Core.Type.Unity.Update
import           Core.Type.Unity.Request
import           Core.Web.Unity
import           Core.Data.Unity

import           Control.Concurrent
import           Control.Monad

import           Utils.Config

import           Plugin.BaikeQuerier
import           Plugin.NoteSaver
import           Plugin.Timer
import           Plugin.DiceHelper
import           Plugin.SolidotFetcher

getHandler :: Text.Text -> ((Text.Text, Update) -> IO [SendMsg])
getHandler cmdHeader =
  case Text.toLower cmdHeader of
    "/bk" -> processQuery

    "/svnote" -> saveNote
    "/note" -> queryNote

    "/timer" -> addTimer
    "/cxltimer" -> cancelTimer
    "/pd" -> setPomodoro

    "/dc" -> processDiceRolling

    "/subsd" -> addSubscriber
    "/cxlsubsd" -> rmSubscribe

    "/help" -> getCommandHelps
    _     -> pure $ pure []

getMsgs2Send :: Update -> IO [SendMsg]
getMsgs2Send update =
  if Text.head msgTxt /= '/'
     then pure []
     else
       let command = Text.breakOn " " msgTxt in
       getHandler (fst command) (snd command, update)
  where msgTxt = message_text update

commandProcess :: Update -> Config -> IO ()
commandProcess update config = do
  msgs <- getMsgs2Send update
  traverse_ (`sendTextMsg` config) msgs

checkPluginRequirements :: IO ()
checkPluginRequirements = do
  let rqmt = map ("wldata/"<>) $ mconcat [ timerRequirement
                                         , sfRequirement
                                         , noteRequirement
                                         ]
  de <- doesDirectoryExist "wldata"
  _ <- if de then pure () else createDirectory "wldata"
  traverse_ (\fileName -> do
    fe <- doesFileExist fileName
    if fe then pure () else writeFile fileName "") rqmt


-- This is an automatic operation which checks plugin events every 1 minute.
checkPluginEventsIn1 :: Config -> IO ()
checkPluginEventsIn1 config = forever $ do
  msgs <- sequence [checkTimer, checkNewOfSolidot]
  traverse_ (`sendTextMsg` config) $ mconcat msgs
  threadDelay 60000000

checkPluginEventsIn10 :: Config -> IO ()
checkPluginEventsIn10 config = forever $ do
  msgs <- sequence [checkNewOfSolidot]
  traverse_ (`sendTextMsg` config) $ mconcat msgs
  threadDelay 600000000

getCommandHelps :: (Text.Text, Update) -> IO [SendMsg]
getCommandHelps (_, update) = do
  let helps = (mconcat.intersperse "\n")
                 [ baikeHelps
                 , noteHelps
                 , timerHelps
                 , diceHelps
                 , solidotHelps
                 ]
  pure [makeReqFromUpdate update helps]
