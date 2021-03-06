{-# LANGUAGE OverloadedStrings #-}
module Core.Web.Mirai where

import           Control.Lens
import           Core.Type.Mirai.Request
import           Data.Aeson
import           Data.ByteString.Lazy
import           Network.Wreq
import           Utils.Config

sendGrpMsg
  :: String -> [Message] -> Config -> Maybe String -> IO (Response ByteString)
sendGrpMsg grpId msgs config replyId = postCqRequest
  (config ^. mirai_server)
  "sendGroupMessage"
  (toJSON
    (SendMRMsg Nothing (Just grpId) (config ^. mirai_session_key) replyId msgs)
  )

sendTempMsg
  :: String -> String -> [Message] -> Config -> IO (Response ByteString)
sendTempMsg userId grpId msgs config = postCqRequest
  (config ^. mirai_server)
  "sendTempMessage"
  (toJSON
    (SendMRMsg (Just userId)
               (Just grpId)
               (config ^. mirai_session_key)
               Nothing
               msgs
    )
  )

sendPrivMsg :: String -> [Message] -> Config -> IO (Response ByteString)
sendPrivMsg userId msgs config = postCqRequest
  (config ^. mirai_server)
  "sendFriendMessage"
  (toJSON
    (SendMRMsg (Just userId) Nothing (config ^. mirai_session_key) Nothing msgs)
  )

postCqRequest :: String -> String -> Value -> IO (Response ByteString)
postCqRequest cqSvr method = postWith opts (cqSvr ++ method)
 where
  opts = defaults & header "Content-Type" .~ ["text/plain; charset=UTF-8"]
