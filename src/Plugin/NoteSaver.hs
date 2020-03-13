{-# LANGUAGE OverloadedStrings #-}
module Plugin.NoteSaver where

import           Core.Web.CoolQ               as CQ
import           Core.Type.CoolQ.Update       as CQ
import           Core.Data.CoolQ              as CQ

import Utils.Config
import Utils.Logging

import Control.Concurrent
import Data.Maybe
import Data.Text                 as Text
import Data.Text.IO              as Text

searchBetween :: Text -> Text -> Text -> Maybe Text
searchBetween left right content =
  case breakOnEnd left content of
    ("",_) -> Nothing
    (_, fstRound) -> Just $ fst (breakOn right fstRound)

saveNote :: Text -> Text -> IO ()
saveNote key value = Text.appendFile "notes.txt" ("`{"<>key<>">`"<>value<>"!^\n")

queryNote :: Text -> IO (Maybe Text)
queryNote key = do
  notes <- Text.readFile "notes.txt"
  pure $ searchBetween ("`{"<>key<>">`") "!^" notes

processNoteOp :: Config -> CQ.Update -> IO (Maybe RespBS)
processNoteOp config cqUpdate =
  let msgTxt = getText (CQ.message cqUpdate) in
    case Text.take 4 msgTxt of
      "/sn " ->
        let content = Text.dropWhile (==' ') (Text.drop 4 msgTxt) in
        if Text.dropWhile (/=' ') content /= ""
          then do
            let key = Text.takeWhile (/=' ') content
                value = Text.dropWhile (/=' ') content
            _ <- saveNote key value
            logWT Info $
              "Note: ["<>Text.unpack key<>"]"<>Text.unpack value<>"saved from"<>show (fromJust (user_id cqUpdate))<>"."
            Just <$> CQ.sendBackTextMsg "Note saved." cqUpdate config
          else pure Nothing
      "/qn " ->
        if Text.replace " " "" msgTxt /= "/qn"
           then do
             note <- queryNote (Text.replace " " "" $ Text.drop 4 msgTxt)
             case note of
               Just n -> Just <$> CQ.sendBackTextMsg n cqUpdate config
               _      -> Just <$> CQ.sendBackTextMsg "No note found." cqUpdate config
            else pure Nothing
      _ -> pure Nothing

