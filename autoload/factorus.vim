" vim: ts=8 sw=4 sts=4 et foldenable foldmethod=marker foldcolumn=1

scriptencoding utf-8

" Initialization {{{1

if exists(':Factorus') == 0
    runtime plugin/factorus.vim
endif

" Search Constants {{{1
let s:search_chars = '\u0024-\u0024\u0030-\u0039\u0041-\u005a\u005f-\u005f\u0061-\u007a\u007f-\u009f\u00a2-\u00a5\u00aa-\u00aa\u00ad-\u00ad\u00b5-\u00b5\u00ba-\u00ba\u00c0-\u00d6\u00d8-\u00f6\u00f8-\u02c1\u02c6-\u02d1\u02e0-\u02e4\u02ec-\u02ec\u02ee-\u02ee\u0300-\u0374\u0376-\u0377\u037a-\u037d\u0386-\u0386\u0388-\u038a\u038c-\u038c\u038e-\u03a1\u03a3-\u03f5\u03f7-\u0481\u0483-\u0487\u048a-\u0527\u0531-\u0556\u0559-\u0559\u0561-\u0587\u058f-\u058f\u0591-\u05bd\u05bf-\u05bf\u05c1-\u05c2\u05c4-\u05c5\u05c7-\u05c7\u05d0-\u05ea\u05f0-\u05f2\u0600-\u0604\u060b-\u060b\u0610-\u061a\u0620-\u0669\u066e-\u06d3\u06d5-\u06dd\u06df-\u06e8\u06ea-\u06fc\u06ff-\u06ff\u070f-\u074a\u074d-\u07b1\u07c0-\u07f5\u07fa-\u07fa\u0800-\u082d\u0840-\u085b\u08a0-\u08a0\u08a2-\u08ac\u08e4-\u08fe\u0900-\u0963\u0966-\u096f\u0971-\u0977\u0979-\u097f\u0981-\u0983\u0985-\u098c\u098f-\u0990\u0993-\u09a8\u09aa-\u09b0\u09b2-\u09b2\u09b6-\u09b9\u09bc-\u09c4\u09c7-\u09c8\u09cb-\u09ce\u09d7-\u09d7\u09dc-\u09dd\u09df-\u09e3\u09e6-\u09f3\u09fb-\u09fb\u0a01-\u0a03\u0a05-\u0a0a\u0a0f-\u0a10\u0a13-\u0a28\u0a2a-\u0a30\u0a32-\u0a33\u0a35-\u0a36\u0a38-\u0a39\u0a3c-\u0a3c\u0a3e-\u0a42\u0a47-\u0a48\u0a4b-\u0a4d\u0a51-\u0a51\u0a59-\u0a5c\u0a5e-\u0a5e\u0a66-\u0a75\u0a81-\u0a83\u0a85-\u0a8d\u0a8f-\u0a91\u0a93-\u0aa8\u0aaa-\u0ab0\u0ab2-\u0ab3\u0ab5-\u0ab9\u0abc-\u0ac5\u0ac7-\u0ac9\u0acb-\u0acd\u0ad0-\u0ad0\u0ae0-\u0ae3\u0ae6-\u0aef\u0af1-\u0af1\u0b01-\u0b03\u0b05-\u0b0c\u0b0f-\u0b10\u0b13-\u0b28\u0b2a-\u0b30\u0b32-\u0b33\u0b35-\u0b39\u0b3c-\u0b44\u0b47-\u0b48\u0b4b-\u0b4d\u0b56-\u0b57\u0b5c-\u0b5d\u0b5f-\u0b63\u0b66-\u0b6f\u0b71-\u0b71\u0b82-\u0b83\u0b85-\u0b8a\u0b8e-\u0b90\u0b92-\u0b95\u0b99-\u0b9a\u0b9c-\u0b9c\u0b9e-\u0b9f\u0ba3-\u0ba4\u0ba8-\u0baa\u0bae-\u0bb9\u0bbe-\u0bc2\u0bc6-\u0bc8\u0bca-\u0bcd\u0bd0-\u0bd0\u0bd7-\u0bd7\u0be6-\u0bef\u0bf9-\u0bf9\u0c01-\u0c03\u0c05-\u0c0c\u0c0e-\u0c10\u0c12-\u0c28\u0c2a-\u0c33\u0c35-\u0c39\u0c3d-\u0c44\u0c46-\u0c48\u0c4a-\u0c4d\u0c55-\u0c56\u0c58-\u0c59\u0c60-\u0c63\u0c66-\u0c6f\u0c82-\u0c83\u0c85-\u0c8c\u0c8e-\u0c90\u0c92-\u0ca8\u0caa-\u0cb3\u0cb5-\u0cb9\u0cbc-\u0cc4\u0cc6-\u0cc8\u0cca-\u0ccd\u0cd5-\u0cd6\u0cde-\u0cde\u0ce0-\u0ce3\u0ce6-\u0cef\u0cf1-\u0cf2\u0d02-\u0d03\u0d05-\u0d0c\u0d0e-\u0d10\u0d12-\u0d3a\u0d3d-\u0d44\u0d46-\u0d48\u0d4a-\u0d4e\u0d57-\u0d57\u0d60-\u0d63\u0d66-\u0d6f\u0d7a-\u0d7f\u0d82-\u0d83\u0d85-\u0d96\u0d9a-\u0db1\u0db3-\u0dbb\u0dbd-\u0dbd\u0dc0-\u0dc6\u0dca-\u0dca\u0dcf-\u0dd4\u0dd6-\u0dd6\u0dd8-\u0ddf\u0df2-\u0df3\u0e01-\u0e3a\u0e3f-\u0e4e\u0e50-\u0e59\u0e81-\u0e82\u0e84-\u0e84\u0e87-\u0e88\u0e8a-\u0e8a\u0e8d-\u0e8d\u0e94-\u0e97\u0e99-\u0e9f\u0ea1-\u0ea3\u0ea5-\u0ea5\u0ea7-\u0ea7\u0eaa-\u0eab\u0ead-\u0eb9\u0ebb-\u0ebd\u0ec0-\u0ec4\u0ec6-\u0ec6\u0ec8-\u0ecd\u0ed0-\u0ed9\u0edc-\u0edf\u0f00-\u0f00\u0f18-\u0f19\u0f20-\u0f29\u0f35-\u0f35\u0f37-\u0f37\u0f39-\u0f39\u0f3e-\u0f47\u0f49-\u0f6c\u0f71-\u0f84\u0f86-\u0f97\u0f99-\u0fbc\u0fc6-\u0fc6\u1000-\u1049\u1050-\u109d\u10a0-\u10c5\u10c7-\u10c7\u10cd-\u10cd\u10d0-\u10fa\u10fc-\u1248\u124a-\u124d\u1250-\u1256\u1258-\u1258\u125a-\u125d\u1260-\u1288\u128a-\u128d\u1290-\u12b0\u12b2-\u12b5\u12b8-\u12be\u12c0-\u12c0\u12c2-\u12c5\u12c8-\u12d6\u12d8-\u1310\u1312-\u1315\u1318-\u135a\u135d-\u135f\u1380-\u138f\u13a0-\u13f4\u1401-\u166c\u166f-\u167f\u1681-\u169a\u16a0-\u16ea\u16ee-\u16f0\u1700-\u170c\u170e-\u1714\u1720-\u1734\u1740-\u1753\u1760-\u176c\u176e-\u1770\u1772-\u1773\u1780-\u17d3\u17d7-\u17d7\u17db-\u17dd\u17e0-\u17e9\u180b-\u180d\u1810-\u1819\u1820-\u1877\u1880-\u18aa\u18b0-\u18f5\u1900-\u191c\u1920-\u192b\u1930-\u193b\u1946-\u196d\u1970-\u1974\u1980-\u19ab\u19b0-\u19c9\u19d0-\u19d9\u1a00-\u1a1b\u1a20-\u1a5e\u1a60-\u1a7c\u1a7f-\u1a89\u1a90-\u1a99\u1aa7-\u1aa7\u1b00-\u1b4b\u1b50-\u1b59\u1b6b-\u1b73\u1b80-\u1bf3\u1c00-\u1c37\u1c40-\u1c49\u1c4d-\u1c7d\u1cd0-\u1cd2\u1cd4-\u1cf6\u1d00-\u1de6\u1dfc-\u1f15\u1f18-\u1f1d\u1f20-\u1f45\u1f48-\u1f4d\u1f50-\u1f57\u1f59-\u1f59\u1f5b-\u1f5b\u1f5d-\u1f5d\u1f5f-\u1f7d\u1f80-\u1fb4\u1fb6-\u1fbc\u1fbe-\u1fbe\u1fc2-\u1fc4\u1fc6-\u1fcc\u1fd0-\u1fd3\u1fd6-\u1fdb\u1fe0-\u1fec\u1ff2-\u1ff4\u1ff6-\u1ffc\u200b-\u200f\u202a-\u202e\u203f-\u2040\u2054-\u2054\u2060-\u2064\u206a-\u206f\u2071-\u2071\u207f-\u207f\u2090-\u209c\u20a0-\u20ba\u20d0-\u20dc\u20e1-\u20e1\u20e5-\u20f0\u2102-\u2102\u2107-\u2107\u210a-\u2113\u2115-\u2115\u2119-\u211d\u2124-\u2124\u2126-\u2126\u2128-\u2128\u212a-\u212d\u212f-\u2139\u213c-\u213f\u2145-\u2149\u214e-\u214e\u2160-\u2188\u2c00-\u2c2e\u2c30-\u2c5e\u2c60-\u2ce4\u2ceb-\u2cf3\u2d00-\u2d25\u2d27-\u2d27\u2d2d-\u2d2d\u2d30-\u2d67\u2d6f-\u2d6f\u2d7f-\u2d96\u2da0-\u2da6\u2da8-\u2dae\u2db0-\u2db6\u2db8-\u2dbe\u2dc0-\u2dc6\u2dc8-\u2dce\u2dd0-\u2dd6\u2dd8-\u2dde\u2de0-\u2dff\u2e2f-\u2e2f\u3005-\u3007\u3021-\u302f\u3031-\u3035\u3038-\u303c\u3041-\u3096\u3099-\u309a\u309d-\u309f\u30a1-\u30fa\u30fc-\u30ff\u3105-\u312d\u3131-\u318e\u31a0-\u31ba\u31f0-\u31ff\u3400-\u4db5\u4e00-\u9fcc\ua000-\ua48c\ua4d0-\ua4fd\ua500-\ua60c\ua610-\ua62b\ua640-\ua66f\ua674-\ua67d\ua67f-\ua697\ua69f-\ua6f1\ua717-\ua71f\ua722-\ua788\ua78b-\ua78e\ua790-\ua793\ua7a0-\ua7aa\ua7f8-\ua827\ua838-\ua838\ua840-\ua873\ua880-\ua8c4\ua8d0-\ua8d9\ua8e0-\ua8f7\ua8fb-\ua8fb\ua900-\ua92d\ua930-\ua953\ua960-\ua97c\ua980-\ua9c0\ua9cf-\ua9d9\uaa00-\uaa36\uaa40-\uaa4d\uaa50-\uaa59\uaa60-\uaa76\uaa7a-\uaa7b\uaa80-\uaac2\uaadb-\uaadd\uaae0-\uaaef\uaaf2-\uaaf6\uab01-\uab06\uab09-\uab0e\uab11-\uab16\uab20-\uab26\uab28-\uab2e\uabc0-\uabea\uabec-\uabed\uabf0-\uabf9\uac00-\ud7a3\ud7b0-\ud7c6\ud7cb-\ud7fb\uf900-\ufa6d\ufa70-\ufad9\ufb00-\ufb06\ufb13-\ufb17\ufb1d-\ufb28\ufb2a-\ufb36\ufb38-\ufb3c\ufb3e-\ufb3e\ufb40-\ufb41\ufb43-\ufb44\ufb46-\ufbb1\ufbd3-\ufd3d\ufd50-\ufd8f\ufd92-\ufdc7\ufdf0-\ufdfc\ufe00-\ufe0f\ufe20-\ufe26\ufe33-\ufe34\ufe4d-\ufe4f\ufe69-\ufe69\ufe70-\ufe74\ufe76-\ufefc\ufeff-\ufeff\uff04-\uff04\uff10-\uff19\uff21-\uff3a\uff3f-\uff3f\uff41-\uff5a\uff66-\uffbe\uffc2-\uffc7\uffca-\uffcf\uffd2-\uffd7\uffda-\uffdc\uffe0-\uffe1\uffe5-\uffe6\ufff9-\ufffb'

let s:start_chars = '\u0024\u0041-\u005a\u005f-\u005f\u0061-\u007a\u00a2-\u00a5\u00aa-\u00aa\u00b5-\u00b5\u00ba-\u00ba\u00c0-\u00d6\u00d8-\u00f6\u00f8-\u02c1\u02c6-\u02d1\u02e0-\u02e4\u02ec-\u02ec\u02ee-\u02ee\u0370-\u0374\u0376-\u0377\u037a-\u037d\u0386-\u0386\u0388-\u038a\u038c-\u038c\u038e-\u03a1\u03a3-\u03f5\u03f7-\u0481\u048a-\u0527\u0531-\u0556\u0559-\u0559\u0561-\u0587\u058f-\u058f\u05d0-\u05ea\u05f0-\u05f2\u060b-\u060b\u0620-\u064a\u066e-\u066f\u0671-\u06d3\u06d5-\u06d5\u06e5-\u06e6\u06ee-\u06ef\u06fa-\u06fc\u06ff-\u06ff\u0710-\u0710\u0712-\u072f\u074d-\u07a5\u07b1-\u07b1\u07ca-\u07ea\u07f4-\u07f5\u07fa-\u07fa\u0800-\u0815\u081a-\u081a\u0824-\u0824\u0828-\u0828\u0840-\u0858\u08a0-\u08a0\u08a2-\u08ac\u0904-\u0939\u093d-\u093d\u0950-\u0950\u0958-\u0961\u0971-\u0977\u0979-\u097f\u0985-\u098c\u098f-\u0990\u0993-\u09a8\u09aa-\u09b0\u09b2-\u09b2\u09b6-\u09b9\u09bd-\u09bd\u09ce-\u09ce\u09dc-\u09dd\u09df-\u09e1\u09f0-\u09f3\u09fb-\u09fb\u0a05-\u0a0a\u0a0f-\u0a10\u0a13-\u0a28\u0a2a-\u0a30\u0a32-\u0a33\u0a35-\u0a36\u0a38-\u0a39\u0a59-\u0a5c\u0a5e-\u0a5e\u0a72-\u0a74\u0a85-\u0a8d\u0a8f-\u0a91\u0a93-\u0aa8\u0aaa-\u0ab0\u0ab2-\u0ab3\u0ab5-\u0ab9\u0abd-\u0abd\u0ad0-\u0ad0\u0ae0-\u0ae1\u0af1-\u0af1\u0b05-\u0b0c\u0b0f-\u0b10\u0b13-\u0b28\u0b2a-\u0b30\u0b32-\u0b33\u0b35-\u0b39\u0b3d-\u0b3d\u0b5c-\u0b5d\u0b5f-\u0b61\u0b71-\u0b71\u0b83-\u0b83\u0b85-\u0b8a\u0b8e-\u0b90\u0b92-\u0b95\u0b99-\u0b9a\u0b9c-\u0b9c\u0b9e-\u0b9f\u0ba3-\u0ba4\u0ba8-\u0baa\u0bae-\u0bb9\u0bd0-\u0bd0\u0bf9-\u0bf9\u0c05-\u0c0c\u0c0e-\u0c10\u0c12-\u0c28\u0c2a-\u0c33\u0c35-\u0c39\u0c3d-\u0c3d\u0c58-\u0c59\u0c60-\u0c61\u0c85-\u0c8c\u0c8e-\u0c90\u0c92-\u0ca8\u0caa-\u0cb3\u0cb5-\u0cb9\u0cbd-\u0cbd\u0cde-\u0cde\u0ce0-\u0ce1\u0cf1-\u0cf2\u0d05-\u0d0c\u0d0e-\u0d10\u0d12-\u0d3a\u0d3d-\u0d3d\u0d4e-\u0d4e\u0d60-\u0d61\u0d7a-\u0d7f\u0d85-\u0d96\u0d9a-\u0db1\u0db3-\u0dbb\u0dbd-\u0dbd\u0dc0-\u0dc6\u0e01-\u0e30\u0e32-\u0e33\u0e3f-\u0e46\u0e81-\u0e82\u0e84-\u0e84\u0e87-\u0e88\u0e8a-\u0e8a\u0e8d-\u0e8d\u0e94-\u0e97\u0e99-\u0e9f\u0ea1-\u0ea3\u0ea5-\u0ea5\u0ea7-\u0ea7\u0eaa-\u0eab\u0ead-\u0eb0\u0eb2-\u0eb3\u0ebd-\u0ebd\u0ec0-\u0ec4\u0ec6-\u0ec6\u0edc-\u0edf\u0f00-\u0f00\u0f40-\u0f47\u0f49-\u0f6c\u0f88-\u0f8c\u1000-\u102a\u103f-\u103f\u1050-\u1055\u105a-\u105d\u1061-\u1061\u1065-\u1066\u106e-\u1070\u1075-\u1081\u108e-\u108e\u10a0-\u10c5\u10c7-\u10c7\u10cd-\u10cd\u10d0-\u10fa\u10fc-\u1248\u124a-\u124d\u1250-\u1256\u1258-\u1258\u125a-\u125d\u1260-\u1288\u128a-\u128d\u1290-\u12b0\u12b2-\u12b5\u12b8-\u12be\u12c0-\u12c0\u12c2-\u12c5\u12c8-\u12d6\u12d8-\u1310\u1312-\u1315\u1318-\u135a\u1380-\u138f\u13a0-\u13f4\u1401-\u166c\u166f-\u167f\u1681-\u169a\u16a0-\u16ea\u16ee-\u16f0\u1700-\u170c\u170e-\u1711\u1720-\u1731\u1740-\u1751\u1760-\u176c\u176e-\u1770\u1780-\u17b3\u17d7-\u17d7\u17db-\u17dc\u1820-\u1877\u1880-\u18a8\u18aa-\u18aa\u18b0-\u18f5\u1900-\u191c\u1950-\u196d\u1970-\u1974\u1980-\u19ab\u19c1-\u19c7\u1a00-\u1a16\u1a20-\u1a54\u1aa7-\u1aa7\u1b05-\u1b33\u1b45-\u1b4b\u1b83-\u1ba0\u1bae-\u1baf\u1bba-\u1be5\u1c00-\u1c23\u1c4d-\u1c4f\u1c5a-\u1c7d\u1ce9-\u1cec\u1cee-\u1cf1\u1cf5-\u1cf6\u1d00-\u1dbf\u1e00-\u1f15\u1f18-\u1f1d\u1f20-\u1f45\u1f48-\u1f4d\u1f50-\u1f57\u1f59-\u1f59\u1f5b-\u1f5b\u1f5d-\u1f5d\u1f5f-\u1f7d\u1f80-\u1fb4\u1fb6-\u1fbc\u1fbe-\u1fbe\u1fc2-\u1fc4\u1fc6-\u1fcc\u1fd0-\u1fd3\u1fd6-\u1fdb\u1fe0-\u1fec\u1ff2-\u1ff4\u1ff6-\u1ffc\u203f-\u2040\u2054-\u2054\u2071-\u2071\u207f-\u207f\u2090-\u209c\u20a0-\u20ba\u2102-\u2102\u2107-\u2107\u210a-\u2113\u2115-\u2115\u2119-\u211d\u2124-\u2124\u2126-\u2126\u2128-\u2128\u212a-\u212d\u212f-\u2139\u213c-\u213f\u2145-\u2149\u214e-\u214e\u2160-\u2188\u2c00-\u2c2e\u2c30-\u2c5e\u2c60-\u2ce4\u2ceb-\u2cee\u2cf2-\u2cf3\u2d00-\u2d25\u2d27-\u2d27\u2d2d-\u2d2d\u2d30-\u2d67\u2d6f-\u2d6f\u2d80-\u2d96\u2da0-\u2da6\u2da8-\u2dae\u2db0-\u2db6\u2db8-\u2dbe\u2dc0-\u2dc6\u2dc8-\u2dce\u2dd0-\u2dd6\u2dd8-\u2dde\u2e2f-\u2e2f\u3005-\u3007\u3021-\u3029\u3031-\u3035\u3038-\u303c\u3041-\u3096\u309d-\u309f\u30a1-\u30fa\u30fc-\u30ff\u3105-\u312d\u3131-\u318e\u31a0-\u31ba\u31f0-\u31ff\u3400-\u4db5\u4e00-\u9fcc\ua000-\ua48c\ua4d0-\ua4fd\ua500-\ua60c\ua610-\ua61f\ua62a-\ua62b\ua640-\ua66e\ua67f-\ua697\ua6a0-\ua6ef\ua717-\ua71f\ua722-\ua788\ua78b-\ua78e\ua790-\ua793\ua7a0-\ua7aa\ua7f8-\ua801\ua803-\ua805\ua807-\ua80a\ua80c-\ua822\ua838-\ua838\ua840-\ua873\ua882-\ua8b3\ua8f2-\ua8f7\ua8fb-\ua8fb\ua90a-\ua925\ua930-\ua946\ua960-\ua97c\ua984-\ua9b2\ua9cf-\ua9cf\uaa00-\uaa28\uaa40-\uaa42\uaa44-\uaa4b\uaa60-\uaa76\uaa7a-\uaa7a\uaa80-\uaaaf\uaab1-\uaab1\uaab5-\uaab6\uaab9-\uaabd\uaac0-\uaac0\uaac2-\uaac2\uaadb-\uaadd\uaae0-\uaaea\uaaf2-\uaaf4\uab01-\uab06\uab09-\uab0e\uab11-\uab16\uab20-\uab26\uab28-\uab2e\uabc0-\uabe2\uac00-\ud7a3\ud7b0-\ud7c6\ud7cb-\ud7fb\uf900-\ufa6d\ufa70-\ufad9\ufb00-\ufb06\ufb13-\ufb17\ufb1d-\ufb1d\ufb1f-\ufb28\ufb2a-\ufb36\ufb38-\ufb3c\ufb3e-\ufb3e\ufb40-\ufb41\ufb43-\ufb44\ufb46-\ufbb1\ufbd3-\ufd3d\ufd50-\ufd8f\ufd92-\ufdc7\ufdf0-\ufdfc\ufe33-\ufe34\ufe4d-\ufe4f\ufe69-\ufe69\ufe70-\ufe74\ufe76-\ufefc\uff04-\uff04\uff21-\uff3a\uff3f-\uff3f\uff41-\uff5a\uff66-\uffbe\uffc2-\uffc7\uffca-\uffcf\uffd2-\uffd7\uffda-\uffdc\uffe0-\uffe1\uffe5-\uffe6'

let s:collection_identifier = '\(\[\]\|<[' . s:start_chars . '][<>,.' . s:search_chars . ']*>\)'

let g:factorus_java_identifier = '[' . s:start_chars . '][' . s:search_chars . ']*'
let g:remainder_query = '\_[,<>.[:space:]' . s:search_chars . ']*'

let g:factorus_tag_query = '^\s*\(public\s\|private\s\|protected\s\)\=\s*\(static\s\)\=\s*\(final\s\)\=\s*\(class\s\|enum\s\|' . g:factorus_java_identifier . s:collection_identifier . '\=\_s*' . g:factorus_java_identifier . s:collection_identifier . '\=' . g:remainder_query . '(\)'
let g:java_keywords = '[^' . s:search_chars . ']\+\(assert\|break\|case\|catch\|const\|continue\|default\|do\|else\|false\|finally\|float\|for\|goto\|if\|import\|instanceof\|new\|null\|package\|return\|strictfp\|super\|switch\|this\|throw\|transient\|true\|try\|volatile\|while\)[^' . s:search_chars . ']\+'

" Functions {{{1

function! s:getNext(word,flags)
    let [a:line,a:col] = [line('.'),col('.')]
    call search(a:word,a:flags)
    let [a:s_line,a:s_col] = [line('.'),col('.')]
    call cursor(a:line,a:col)
    return [a:s_line,a:s_col]
endfunction

function! s:isBefore(x,y)
    if a:x[0] < a:y[0] || (a:x[0] == a:y[0] && a:x[1] < a:y[1])
        return 1
    endif
    return 0
endfunction

function! s:findTags(temp_file,search_string,append)
    let a:fout = a:append == 'yes' ? '>>' : '>'
    call system('find -name "*" -exec grep -l "' . a:search_string . '" {} + ' . a:fout . ' ' . a:temp_file . ' 2> /dev/null')
endfunction

function! s:narrowTags(temp_file,search_string)
    let a:n_temp_file = a:temp_file . '2'
    call system('cat ' . a:temp_file . ' | xargs grep -l "' . a:search_string . '" {} + > ' . a:n_temp_file)
    call system('mv ' . a:n_temp_file . ' ' . a:temp_file)
endfunction

function! s:getClosingBracket(stack)

    let a:mark = 0

    let a:orig = [line('.'),col('.')]
    let a:pos = [line('.'),col('.')]
    let a:open = [line('.'),col('.')]
    let a:close = [line('.'),col('.')]

    while 1 == 1 
        let a:open = s:getNext('{','W')
        let a:close = s:getNext('}','W')

        if a:open == a:pos || a:close == a:pos
            break
        endif

        if s:isBefore(a:open,a:close) == 1
            let a:pos = copy(a:open)
            let a:mark += 1
        else
            let a:pos = copy(a:close)
            let a:mark -= 1
        endif

        if a:mark < a:stack
            break
        endif

        call cursor(a:pos[0],a:pos[1])
    endwhile

    call cursor(a:orig[0],a:orig[1])
    return a:pos

endfunction

function! s:isValidTag(line)

    let a:first_char = strpart(substitute(getline(a:line),'\s*','','g'),0,1)   
    if a:first_char == '*' || a:first_char == '/'
        return 0
    endif

    let a:has_keyword = match(getline(a:line),g:java_keywords)
    if a:has_keyword >= 0
        return 0
    endif

    if match(getline(a:line-1),'new.*{') >= 0
        return 0   
    endif

    return 1

endfunction

function! s:getCurrentTag()

    let [a:line,a:col] = [line('.'),col('.')]
    let a:is_match = match(getline(a:line),g:factorus_tag_query)
    if a:is_match >= 0
        if s:isValidTag(a:line) == 1
            return a:line
        endif
    endif

    let a:is_valid = 0
    while a:is_valid == 0
        let a:func = s:getNext(g:factorus_tag_query,'b')
        if a:func[0] > a:line
            break
        endif
        call cursor(a:func[0],a:func[1])

        let a:is_valid = s:isValidTag(a:func[0])
        continue

    endwhile

    call cursor(a:line,a:col)
    return a:func[0]

endfunction

function! s:getClassTag()
    let [a:line,a:col] = [line('.'),col('.')]
    call cursor(1,1)
    let a:class_tag = s:getNext(g:factorus_tag_query,'')
    call cursor(a:line,a:col)
    return a:class_tag[0]
endfunction

function! s:getNextDec(class_name,...)
    let a:ident = a:0 > 0 ? a:1 : g:factorus_java_identifier
    let a:get_variable = '^[^/*]*\([,([:space:]]' . a:class_name . s:collection_identifier . '\=\s*\)\(' . a:ident . '\)[:;=,[:space:])].*'

    let a:line = line('.')

    let a:match = s:getNext(a:get_variable,'W')
    if a:match[0] > a:line
        let a:var = substitute(getline(a:match[0]),a:get_variable,'\3','')
        return [a:var,a:match]
    endif

    return ['none',[0,0]]

endfunction

function! s:jumpToNearest(vars,next,paren) abort

    let a:start = [line('.'),col('.')]
    let [a:min,a:jump,a:add] = a:next[1][0] > 0 ? [a:next[1],a:next[0],1] : [[line('$'),1000], 'none' ,1]
    let a:count = len(a:vars) - 1

    while a:count >= 0
        let a:var = a:vars[a:count]
        let a:search = '^\s*[^/*]*' . a:var[0] . a:paren
        let a:match = s:getNext(a:search,'W') 
        if s:isBefore(a:var[1],a:match) == 1
            call remove(a:vars,a:count)
        elseif a:match[0] > line('.') && s:isBefore(a:match,a:min)
            let a:add = 0
            let a:min = copy(a:match)
            let a:jump = a:var[0]
        endif
        let a:count -= 1
    endwhile

    call cursor(a:min[0],a:min[1])

    return [a:jump,a:add]

endfunction

function! s:updateClassFile(class_name,old_name,new_name) abort
    let a:prev = [line('.'),col('.')]
    call cursor(1,1)
    let a:restricted = 0
    let a:here = line('.')

    let a:search = ['\(\s\+\|\s\+this\.\)\(' . a:old_name . '\)' , '\(\s\+this\.\)\(' . a:old_name . '\)']

    let [a:dec,a:next] = s:getNextDec(a:class_name,a:old_name)
    if a:next[0] == 0
        let a:next = line('$')
    endif
    while 1 == 1
        let a:here = line('.')
        let a:rep = s:getNext(a:search[a:restricted],'W')
        if a:rep[0] == a:here
            break
        endif
        call cursor(a:rep[0],1)

        if a:rep[0] >= a:next[0]
            call cursor(a:next[0],1)
            let a:restricted = 1 - a:restricted
            if a:restricted == 1
                let a:next = factorus#getNextTag()
            else
                let [a:dec,a:next] = s:getNextDec(a:class_name,a:old_name)
                if a:next[0] == 0
                    let a:next = [line('$'),1]
                endif
            endif
            continue
        endif

        execute 's/' . a:search[a:restricted] . '/\1' . a:new_name . '/g'
    endwhile
    call cursor(a:prev[0],a:prev[1])

    silent write
endfunction

function! s:updateMethodFile(file_name,class_name,method_name,new_name,paren) abort
    execute 'silent edit ' . a:file_name
    let a:vars = []
    let a:here = line('.')
    let a:next = s:getNextDec(a:class_name)

    while a:here < line('$')
        let [a:jump,a:add] = s:jumpToNearest(a:vars,a:next,a:paren)
        if line('.') == a:here
            break
        elseif a:add == 1
            call add(a:vars,[a:next[0] . '\.' . a:method_name,s:getClosingBracket(0)])
            let a:next = s:getNextDec(a:class_name)
        else
            let a:rep = substitute(a:jump,'\.' . a:method_name,'.' . a:new_name,'')
            execute 's/\(\s\=\)' . a:jump . '\s*' . a:paren . '/\1' . a:rep . a:paren . '/g'
        endif
        let a:here = line('.')
    endwhile

    silent write
    if a:file_name != a:class_name . '.java'
        bdelete
    endif
endfunction

function! s:updateMethodFiles(file_name,class_name,method_name,new_name,paren) abort
    let a:files = readfile(a:file_name)
    for file in a:files
        call s:updateMethodFile(file,a:class_name,a:method_name,a:new_name,a:paren)
    endfor
endfunction 

function! s:refactorStatic(old_name,new_name,is_method)

    let a:class_name = expand('%:t:r')
    let a:static_name = a:class_name . '\\.' . a:old_name
    let a:new_static = a:class_name . '.' . a:new_name
    let a:paren = a:is_method == 1 ? '(' : ''

    cd %:p:h
    call s:updateLocalFiles(a:static_name,a:new_static,a:paren)
    call s:updatePackageFiles(expand('%:t:h'),a:new_name,a:paren,a:old_name,1)

    call factorus#gotoTag(1)

    execute '%s/[^.]\<' . a:old_name . '\>' . a:paren . '/ ' . a:new_name . a:paren . '/g'
    silent write

endfunction

function! s:refactorNonStatic(old_name,new_name,is_method,is_local) abort

    let a:orig = line('.')

    let a:class_name = expand('%:t:r')
    let a:paren = a:is_method == 1 ? '(' : ''

    let a:query = '\([^.]\)\<' . a:old_name . '\>' . a:paren
    let a:this = '\([^.]\|this\.\)\<' . a:old_name . '\>' . a:paren

    let a:prev = line('.')

    if a:is_local == 1
        let a:closing = s:getClosingBracket(1)

        while 1 == 1
            let a:prev = line('.')
            let a:next = s:getNext(a:query,'W')
            if a:next[0] == a:prev || s:isBefore(a:closing,a:next)
                break
            endif
            call cursor(a:next[0],a:next[1])
            execute 's/' . a:query . '/\1' . a:new_name . a:paren . '/g'
        endwhile
        silent write
    else
        call s:updateLocalFiles(a:class_name,a:new_name,a:paren,a:old_name)
        call s:updatePackageFiles(a:class_name . '.java',a:new_name,a:paren,a:old_name,0)
    endif

    call cursor(a:orig,1)
    silent edit

endfunction

function! s:updateLocalFiles(class_name,new_name,paren,...)

    let a:method_name = a:0 > 0 ? a:1 : ""
    let a:temp_file = '.' . a:class_name
    call system('ls -p | grep -v / > ' . a:temp_file)
    let a:filter = a:method_name == "" ? a:class_name : a:method_name
    call s:narrowTags(a:temp_file,a:filter)

    if a:method_name == ""
        call system('while read p; do sed -i "s/\<' . a:class_name . '\>' . a:paren . '/' . a:new_name . a:paren . '/g" $p; done <' . a:temp_file)
    else
        call s:updateMethodFiles(a:temp_file,a:class_name,a:method_name,a:new_name,a:paren)
    endif

    call system('rm -rf ' . a:temp_file)

endfunction

function! s:updatePackageFiles(class_file,new_name,paren,...)

    let a:method_name = a:0 > 0 ? a:1 : ""
    let a:is_static = a:0 > 1 ? a:2 : 1

    let a:class_name = substitute(a:class_file,'\.java$','','')
    let a:package_name = system('head -n 1 ' . a:class_file)
    let a:package_name = substitute(a:package_name,'^package *','','')
    let a:package_name = substitute(a:package_name,'[;\n]','','g')
    let a:package_search = substitute(a:package_name,'\.','\\.','g')
    let a:temp_file = '.' . a:class_name

    let a:prev_dir = expand('%:p:h')
    let a:git_dir = system('git rev-parse --show-toplevel')

    execute 'cd ' . a:git_dir

    let a:import_search = a:package_search . '\.' . a:class_name
    let a:import_all_search = a:package_search . '\.\*'

    call s:findTags(a:temp_file, a:import_search, 'no')
    call s:findTags(a:temp_file, a:import_all_search, 'yes')

    let a:filter = a:method_name == "" ? a:class_name : a:method_name
    call s:narrowTags(a:temp_file,a:filter)

    if a:is_static == 1
        let a:old = a:class_name
        let a:new = a:new_name
        if a:method_name != ""
            let a:old = a:class_name . '\\.' . a:method_name
            let a:new = a:class_name . '.' . a:new_name
        endif
        call system('for line in $(cat ' . a:temp_file . '); do if [ -f "$line" ]; then sed -i "s/\<' . a:old . '\>' . a:paren . '/' . a:new . a:paren . '/g" $line; fi done')
    else
        call s:updateMethodFiles(a:temp_file,a:class_name,a:method_name,a:new_name,a:paren)
    endif

    call system('rm -rf ' . a:temp_file)
    execute 'cd ' . a:prev_dir
    return

endfunction

function! factorus#getNextTag()
    return s:getNext(g:factorus_tag_query,'W')
endfunction

function! factorus#gotoTag(head)
    let a:tag = a:head == 1 ? s:getClassTag() : s:getCurrentTag() 
    if a:tag <= line('.')
        call cursor(a:tag,1)
    else
        echo 'No tag found'
    endif
endfunction

function! factorus#refactorClass(new_name) abort

    let a:class_name = expand('%:t:r')
    cd %:p:h

    call s:updateLocalFiles(a:class_name,a:new_name,0)
    call s:updatePackageFiles(expand('%:t:h'),a:new_name,0)

    call system('mv ' . a:class_name . '.java ' . a:new_name . '.java')
    execute 'edit ' . a:new_name . '.java'
    execute '%s/\<' . a:class_name . '\>/' . a:new_name . '/g'
    silent write

    echo 'Re-named class ' . a:class_name . ' to ' . a:new_name

endfunction

function! factorus#refactorField(new_name) abort
    let a:search = '\s*\(public\s\|private\s\|protected\s\)\=\s*\(static\s\)\=\s*\(final\s\)\=\s*\(' . g:factorus_java_identifier . s:collection_identifier . '\=\)\s*\(' . g:factorus_java_identifier . '\)\s*[;=].*'

    let a:line = getline('.')
    let a:is_static = substitute(a:line,a:search,'\2','')
    let a:type = substitute(a:line,a:search,'\4','')
    let a:var = substitute(a:line,a:search,'\6','')

    let a:is_local = s:getClassTag() == s:getCurrentTag() ? 0 : 1
    if a:is_static == ""
        execute 's/' . a:var . '/' . a:new_name . '/'
        call s:updateClassFile(a:type,a:var,a:new_name)
        call s:refactorNonStatic(a:var,a:new_name,0,a:is_local)
    else
        call s:refactorStatic(a:var,a:new_name,0)
    endif

    let a:keyword = a:is_static >= 0 ? 'static' : ''
    echom 'Re-named ' . a:keyword . ' variable ' . a:var . ' to ' . a:new_name
endfunction

function! factorus#refactorMethod(new_name) abort
    call factorus#gotoTag(0)

    let a:method_name = matchstr(getline('.'),'\s\+' . g:factorus_java_identifier . '\s*(')
    let a:method_name = matchstr(a:method_name,'[^[:space:](]\+')
    let a:is_static = match(getline('.'),'\s\+static\s\+[^)]\+(')

    execute 's/\<' . a:method_name . '\>/' . a:new_name . '/'
    silent write

    if a:is_static >= 0
        call s:refactorStatic(a:method_name,a:new_name,1)
    else
        call s:refactorNonStatic(a:method_name,a:new_name,1,0)
    endif

    let a:keyword = a:is_static >= 0 ? 'static' : ''
    echom 'Re-named ' . a:keyword . ' method ' . a:method_name . ' to ' . a:new_name
endfunction

function! factorus#encapsulateField() abort
    let a:search = '\s*\(public\s\|private\s\|protected\s\)\=\s*\(static\s\)\=\s*\(final\s\)\=\s*\(' . g:factorus_java_identifier . s:collection_identifier . '\=\)\s*\(' . g:factorus_java_identifier . '\)\s*[;=].*'

    let a:line = getline('.')
    let a:is_static = substitute(a:line,a:search,'\2','')
    let a:type = substitute(a:line,a:search,'\4','')
    let a:var = substitute(a:line,a:search,'\6','')
    let a:cap = substitute(a:var,'\(.\)\(.*\)','\U\1\E\2','')

    let a:is_local = s:getClassTag() == s:getCurrentTag() ? 0 : 1
    if a:is_local == 1
        echom 'Cannot encapsulate a local variable'
        return
    endif

    if a:is_static == 1
        echom 'Cannot encapsulate a static variable'
        return
    endif

    execute 's/\<public\>/private/'
    let a:get = ["\tpublic " . a:type . " get" . a:cap . "() {" , "\t\treturn " . a:var . ";" , "\t}"]
    let a:set = ["\tpublic void set" . a:cap . "(" . a:type . ' ' . a:var . ") {" , "\t\tthis." . a:var . " = " . a:var . ";" , "\t}"]
    let a:access = a:get + [""] + a:set + [""]

    let a:end = s:getNext('}','b')
    call append(a:end[0] - 1,a:access)
    silent write

    echom 'Created getters and setters for ' . a:var
endfunction
