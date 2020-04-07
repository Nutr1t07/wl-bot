{-# LANGUAGE OverloadedStrings #-}
module Core.Web.Mirai where

import Control.Lens
import Network.Wreq
import Data.Aeson
import Data.Text as Text
import Data.ByteString.Lazy

import Core.Type.Unity.Update
import Core.Type.Mirai.Request
import Core.Type.Universal

import Utils.Config

sendBackTextMsg :: Text -> Update -> Config -> IO (Response ByteString)
sendBackTextMsg textToSend update config =
  case message_type update of
     Private -> sendPrivMsg (user_id update) [Message "Plain" (Just textToSend) Nothing] config (Just $ message_id update)
     Group   -> sendGrpMsg (chat_id update) [Message "Plain" (Just textToSend) Nothing] config (Just $ message_id update)

sendGrpMsg :: Integer -> [Message] -> Config -> Maybe Integer -> IO (Response ByteString)
sendGrpMsg groupId msgs config replyId =
  postCqRequest (config ^. mirai_server) "sendGroupMessage"
    (toJSON (SendMRMsg groupId (config ^. mirai_session_key) replyId msgs))

sendPrivMsg :: Integer -> [Message] -> Config -> Maybe Integer -> IO (Response ByteString)
sendPrivMsg userId msgs config replyId =
  postCqRequest (config ^. mirai_server) "sendFriendMessage"
    (toJSON (SendMRMsg userId (config ^. mirai_session_key) replyId msgs))

postCqRequest :: String -> String -> Value -> IO (Response ByteString)
postCqRequest cqSvr method = postWith opts (cqSvr ++ method)
  where opts = defaults & header "Content-Type" .~ ["text/plain; charset=UTF-8"]