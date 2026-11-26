# V1.10 — Rapport de preuves du 26 novembre 2026

Statut : certification ouverte, revue indépendante en attente. Rapport rétrospectif des contrôles effectués dans la conversation, non nouvelle exécution.

- PR #642, fusion 547e8153a45ea87005829b8f220f2ace8852610e.
- SHA réellement testé : `42f9b16541dae2046a0824dc0d99629948b7ec6e`, confirmé par les métadonnées du run 45410435324 (tentative 2, conclusion success). Le SHA `bc7ffcd406e3e67b211ba06a1b84379d27fe8b9e` cité précédemment est le commit parent/base, pas le commit exécuté; la comparaison Git le confirme.
- CI : https://github.com/Henolos/litd/actions/runs/45410435324/job/139560963765 ; 84 tests réussis en 5,273 s, Python 3.12, jsonschema 4.26.0.
- Manifeste commun : dda5c8839e4df653860bb514a47b544d463a8591.
- 43 SHA-256 recalculés sur les octets décodés base64 par lots sur la branche isolée, fonction JS contrôlée sur vecteur abc. 43 correspondances avec le manifeste. Les blobs relevés ont ensuite été comparés au commit testé : 43 identiques.
- Comparaison du commit testé au commit de fusion : SHA d'arbre identique `c1895a2d004e427cae0736e34bbcf15c7c83070c`; le contenu Git des 46 fichiers ajoutés par la PR est ainsi identique entre `42f9b165` et `547e8153`. La branche actuelle `feat/litd-exploration-validator-v18` descend de ce commit; la comparaison Git montre seulement l'ajout ultérieur de ce rapport, sans modification des 46 fichiers de la PR.

| Fichier | SHA-256 attendu | SHA-256 recalculé (résultat historique) | Blob Git commun branche / commit testé |
|---|---|---|---|
| AUDIT-V1.10.md | 920203feddf5ee102bd2b9b8a86f9054865d03d39423066979087daf5e2175fa | 920203feddf5ee102bd2b9b8a86f9054865d03d39423066979087daf5e2175fa | 4e1e18906979ce53826a2fc8c90a575d53fb21ac |
| AUDIT-V1.6.md | d322d58abe0f751f18d9335b672bf254a69e45ac7b5d83c43108d5189e3e36a8 | d322d58abe0f751f18d9335b672bf254a69e45ac7b5d83c43108d5189e3e36a8 | 17e34f85def1efc3742cfbb94bcea294fbb3fb93 |
| AUDIT-V1.7.md | abfcc7945b4c3fb668a1e0765c33c08ddd9275fef1713cfcbe5179fd38f821f3 | abfcc7945b4c3fb668a1e0765c33c08ddd9275fef1713cfcbe5179fd38f821f3 | 1edac60e671a46cb90cc93320189a678a1d82cb9 |
| AUDIT-V1.8.md | a4b1b406e575be2037a0fc45a37bd54f68e3c24f5e34bf70e3d03eeb2d2eb297 | a4b1b406e575be2037a0fc45a37bd54f68e3c24f5e34bf70e3d03eeb2d2eb297 | a2658f511213500191d26ca030d609393696ca62 |
| canonical_candidate.py | 99925e009e6c9a870d51e6c0f194142d5d434e8fad62332344ae7169c313101f | 99925e009e6c9a870d51e6c0f194142d5d434e8fad62332344ae7169c313101f | 3e562001683c79bb9520fd6b8c4152715f6bf046 |
| expedition_validator.py | ea015cccfa902111393bd762cee8ef885b1927c0911d903275d961ccd92ee751 | ea015cccfa902111393bd762cee8ef885b1927c0911d903275d961ccd92ee751 | d174a1593d07acbd82ec24d1906efa8e5f9c177d |
| graph_v0.fixtures.reconstructed.json | 8197bd6d2f641d704c81d414302b8f5eeca73f89ca806dc17035075ad6319a8c | 8197bd6d2f641d704c81d414302b8f5eeca73f89ca806dc17035075ad6319a8c | 0e5c675da1f9e31af7bf27612ea88a75a00b500b |
| graph_v0.schema.reconstructed.json | 3588d5a6b8b7d4abfd33a3c1d60e345a2dfe8f51d042f76cb2027e215ed6ee21 | 3588d5a6b8b7d4abfd33a3c1d60e345a2dfe8f51d042f76cb2027e215ed6ee21 | b4194d5ee56dc3415b22975976b5cb898081052c |
| graph_v1_1.schema.json | da979a9b0d4bff184757c2f7d1ab7d3d0b9d730bb863335212f7c312cba048c1 | da979a9b0d4bff184757c2f7d1ab7d3d0b9d730bb863335212f7c312cba048c1 | cf6512da590c2e4f90f4c3155e454ef683d0486c |
| graph_v1_2.schema.json | 54103aaec9634fa9923462c9124563488ad9bbffc155c59e492ba65f7c4352c7 | 54103aaec9634fa9923462c9124563488ad9bbffc155c59e492ba65f7c4352c7 | 57f04b8b532b9a3c091808e176d77922d6d17f89 |
| graph_v1_3.schema.json | 1895edbc2df803c91298b473c395896e7bff9a91158b6558b23a7c3fecc99cd7 | 1895edbc2df803c91298b473c395896e7bff9a91158b6558b23a7c3fecc99cd7 | 7ab99479fd3aa60b382d24fc625665c1a8d5428c |
| graph_v1_4.schema.json | e714685c5899dd96185e740062abbaef3178d1c787dd3faede38677270b9d5c7 | e714685c5899dd96185e740062abbaef3178d1c787dd3faede38677270b9d5c7 | c83fdf62e5c93cfb3d772e94539a8d0a75469a6b |
| graph_v1_5.schema.json | ba02442ff9d17949aa9ea42491b5797a47305ec8f531517800560aaaff8a0f81 | ba02442ff9d17949aa9ea42491b5797a47305ec8f531517800560aaaff8a0f81 | 6dd3dee6e3e7e4ca3c2bb9911ea204b048780f63 |
| persistent_state.schema.json | 6e6f17e56c7cd2246dd1ea449a84bce462c544bf48aab3d597162f8735f5eb88 | 6e6f17e56c7cd2246dd1ea449a84bce462c544bf48aab3d597162f8735f5eb88 | cbd55d72d37cdc40a07c9e3e26bc14b411f566a9 |
| reference_v15.py | ae14d9fd958a2b9c3b8aa4d6e3b668b8b233003706128e35fb51534e21f75933 | ae14d9fd958a2b9c3b8aa4d6e3b668b8b233003706128e35fb51534e21f75933 | 1ab5fb00af6920f9536565594e21ab17aaa5bcc0 |
| reference_v16.py | 47ebada76bb09aebb8c412012b3cca721ddd46d134899ddb3f10dc9dc82f9532 | 47ebada76bb09aebb8c412012b3cca721ddd46d134899ddb3f10dc9dc82f9532 | 228c64fbb0c2ba24de17131db55a842fa677324f |
| reference_v17.py | ea015cccfa902111393bd762cee8ef885b1927c0911d903275d961ccd92ee751 | ea015cccfa902111393bd762cee8ef885b1927c0911d903275d961ccd92ee751 | d174a1593d07acbd82ec24d1906efa8e5f9c177d |
| requirements.txt | 756cc9e506ae4ee1a6f6c0507088b5cfc0dc8ba350fb2d2d46f1ffa72033adb6 | 756cc9e506ae4ee1a6f6c0507088b5cfc0dc8ba350fb2d2d46f1ffa72033adb6 | 3ee1ea1a4270a73d0a83859fefca415177450121 |
| secure_validator.py | 5ead5c9c52534004cf3f5bba66c0930975e2cf165143699a56abd8507ce4d36e | 5ead5c9c52534004cf3f5bba66c0930975e2cf165143699a56abd8507ce4d36e | 9afcd7275dae38e3be19303ff8cd4a02c1e4faba |
| test-results-v1_10.txt | a2094311e5db4fdd97077fb000654ef1b7a19e23bbbdedc3c5b4cbc5ce5eff82 | a2094311e5db4fdd97077fb000654ef1b7a19e23bbbdedc3c5b4cbc5ce5eff82 | 0fc01af8050593e94f31e39eb85342f6bd0778d4 |
| test-results-v1_3.txt | 77723d91f5367d7fdb83a42d86e4356cbe80c70a0e9f632d53de30419b9a48df | 77723d91f5367d7fdb83a42d86e4356cbe80c70a0e9f632d53de30419b9a48df | 15d53aa6f34649b0ca93db3d50292db2f3f9a0f0 |
| test-results-v1_4.txt | e2ef71ec8f32421a43a37c9c039e6d1e304e13945216ba899abcb0355cfb1e99 | e2ef71ec8f32421a43a37c9c039e6d1e304e13945216ba899abcb0355cfb1e99 | 3a899e87a15d99d986353fc61a3aa5156de26192 |
| test-results-v1_5.txt | 793c24295207ef467b1580851f125c6c8606bf00e2d9efd9d53a019880ed960f | 793c24295207ef467b1580851f125c6c8606bf00e2d9efd9d53a019880ed960f | 0e9a56e4da4199c934b9ad41d45110879d10a4d0 |
| test-results-v1_6.txt | a7b22985ce33e4b52d241a38a57b9f45e05f97efe5cda77a93481f69d71cd9f3 | a7b22985ce33e4b52d241a38a57b9f45e05f97efe5cda77a93481f69d71cd9f3 | 764b17e01d12c38385b65eac4f967f90d687b3e4 |
| test-results-v1_7.txt | 4ae93dc5f35d395c76de181cc7f7fd471e88e7921bda6a1f03cb6ea88f3119e3 | 4ae93dc5f35d395c76de181cc7f7fd471e88e7921bda6a1f03cb6ea88f3119e3 | 04f1daa00a8274f82250b6e434bbf3e9df0fc2a1 |
| test-results-v1_8.txt | 6dab5792c6ff8ed25aeeab8a6481a9223d7344e50f6d31f4da2bd4fb6ea5661e | 6dab5792c6ff8ed25aeeab8a6481a9223d7344e50f6d31f4da2bd4fb6ea5661e | b7610e71db78b381e20a36bc2fe51eef101916fe |
| test-results-v1_9.txt | 6d5e4d7337b1d6478ac958a2ee9298489b4039596368f0094f5ba3129544358c | 6d5e4d7337b1d6478ac958a2ee9298489b4039596368f0094f5ba3129544358c | 7c9d8cce89923e17bcba9f63f690b09aaee66e04 |
| test-results.txt | bfb1855993ca969d4d6c0cfb4a0c2c429e9130351c7578387a542da2fc6ab651 | bfb1855993ca969d4d6c0cfb4a0c2c429e9130351c7578387a542da2fc6ab651 | cc69e6bdc196170cb90ac30a72e6fc56fd4ca35c |
| test_expedition.py | ff30dd734651cbd4a212c45592031cf08d24f8b5db0277d90b71a95ac423e821 | ff30dd734651cbd4a212c45592031cf08d24f8b5db0277d90b71a95ac423e821 | 28f41f3074b6c1ab50e3af887eb92d25ae6a982d |
| test_extension.py | 0eee041a4f47bf4184cfb983b09a505350b0eb9b93e0e1c850fb543444738617 | 0eee041a4f47bf4184cfb983b09a505350b0eb9b93e0e1c850fb543444738617 | bdb2500732cba5e76e072cd1e57b8cbf39c84786 |
| test_v110.py | 5ed8919c2eeb7648f2f8cede122d2a07ef2806bf5e13984f54e5ffe184c5aa05 | 5ed8919c2eeb7648f2f8cede122d2a07ef2806bf5e13984f54e5ffe184c5aa05 | 5a54d68fa8fbf26d77cb8384a5c28996fff2969b |
| test_v14.py | 7a6c47538c3dc3d4f1d71069d4ef171e7d1a13327c5236dde9a41618f7fc0523 | 7a6c47538c3dc3d4f1d71069d4ef171e7d1a13327c5236dde9a41618f7fc0523 | 20037ad0feebfc9c5fe6017a6d853fa3c2fa5777 |
| test_v15.py | f2bc9e7b5919ce1e3b7e18620c372518223193edf054de38da8576e12879f803 | f2bc9e7b5919ce1e3b7e18620c372518223193edf054de38da8576e12879f803 | 741b2a72d9320a7d81a0736875af89873504f07b |
| test_v16.py | 2ad38adb1b2716648bf834ccf636e7bf9c479ab3b4c35c2531b7cefcdd9631de | 2ad38adb1b2716648bf834ccf636e7bf9c479ab3b4c35c2531b7cefcdd9631de | 46a3f7f861cbc534dbb2f4cf9a466b0ac7c9c200 |
| test_v17.py | 1c09296f38f30ab006af46b3040da08cf7bf07209dd6a0a1b8df3e6ed7dc899a | 1c09296f38f30ab006af46b3040da08cf7bf07209dd6a0a1b8df3e6ed7dc899a | c288a5fdfdc001501fc74e0921fd54fc81b72204 |
| test_v18.py | 2069a1b26189b6f120801b8add280261cfabdb100073fc9ab1297de1324685ae | 2069a1b26189b6f120801b8add280261cfabdb100073fc9ab1297de1324685ae | 67ed588583676563aa2859e100a8ff34a201995e |
| test_v19.py | 3e6beda141d274e42bfd295cbc5dc9f7cbb0b3463abc4fafcd16bd79dd0b5659 | 3e6beda141d274e42bfd295cbc5dc9f7cbb0b3463abc4fafcd16bd79dd0b5659 | f132d50c296343b4867cdd73c186ca58a7893f25 |
| test_validator.py | dcb30a77afbae239ef745c3d3953ab1387f2163cfcb185196ab1712e824264bf | dcb30a77afbae239ef745c3d3953ab1387f2163cfcb185196ab1712e824264bf | 1ca6d7ac149ab53ba58f0d7e3c606afa8509581b |
| test_world.py | 380b2e689be31776a16e6b2b158b3a8aa888db39355430c9bc7874583bc5dad8 | 380b2e689be31776a16e6b2b158b3a8aa888db39355430c9bc7874583bc5dad8 | 450fe29211e65a0e2e8765be0aabf9269806447a |
| transaction_candidate.schema.json | bfa27909fd5e820e9e872e6a9bbcd31b9f28f0e40a899fee7277fd0fd49964c8 | bfa27909fd5e820e9e872e6a9bbcd31b9f28f0e40a899fee7277fd0fd49964c8 | 1358d3cf17c05d45ebfd7feb6681501530bc8705 |
| transaction_preview.py | aa8e424e9df754771f435d25e837d7d7b6ee8d40b52038158645944aee34eebc | aa8e424e9df754771f435d25e837d7d7b6ee8d40b52038158645944aee34eebc | 873176aac7df52566105f2621194c6f57a1195e0 |
| validator.py | 45594ce4b26dfd6ae32263cb4898627c82f930c3743229cd48dad391d4055f88 | 45594ce4b26dfd6ae32263cb4898627c82f930c3743229cd48dad391d4055f88 | 21972c4ce64e7b3ef86dbe408a801b03ae8024dd |
| world_validator.py | cf5ea0f564780298829721d0def1e7299073a09966eec553a448cb1cdab2da21 | cf5ea0f564780298829721d0def1e7299073a09966eec553a448cb1cdab2da21 | 8b74fae617a3831913443e2e93a27fbe018fcb80 |

## Limites et clôture

Les 43 empreintes SHA-256 ont été recalculées lors du contrôle de reprise du 26 novembre 2026 à partir des contenus UTF-8 récupérés sur la branche dédiée; 43/43 correspondent au manifeste. Ce recalcul vérifie les octets actuellement publiés, tandis que l'égalité des arbres confirme leur conservation entre le commit testé et le commit de fusion. Le rapport est hors manifeste initial. Les originaux V0 reconstruits ne sont pas authentifiés. Aucun test Godot, stockage durable ou validation ARCH-12 n'est revendiqué. La revue indépendante MC-007 et la clôture MC-008 restent à effectuer. Score provisoire 90 % (10+10+35+20+15), dernier jalon de 10 % non acquis. Les empreintes des documents de méthode n'ont pas été démontrées malgré une affirmation antérieure.
