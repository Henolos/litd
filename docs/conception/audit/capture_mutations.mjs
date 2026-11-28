// Standalone documentary model, not game implementation. Run: node capture_mutations.mjs
const model = (s,m="none") => {
 const allowed=s.eligible && (!s.restricted || s.ng || m==="ng");
 const transfer=allowed && (s.victory || m==="defeat") && (!s.full || m!=="full");
 return {allowed,transfer,progress:transfer && m!=="delay",occupied:m!=="rank",pa:m==="pa"?2:1,identities:m==="duplicate"?2:1,transport:m==="transport"};
};
const cases=[
 ["ARCH-07",{eligible:true,restricted:true,ng:false,victory:true,full:false},"allowed",false],
 ["CAP-I01",{eligible:true,restricted:false,ng:false,victory:false,full:false},"transfer",false],
 ["CAP-J02",{eligible:true,restricted:false,ng:false,victory:true,full:true},"transfer",true],
 ["CAP-J11",{eligible:true,restricted:false,ng:false,victory:true,full:true},"progress",true],
 ["CAP-K02",{},"occupied",true],
 ["CAP-D12",{},"pa",1],
 ["CAP-K12",{},"identities",1],
 ["CAP-HUB",{},"transport",false]
];
const mutations=["ng","defeat","full","delay","rank","pa","duplicate","transport"];
const failures=m=>cases.filter(([id,s,k,v])=>model(s,m)[k]!==v).map(x=>x[0]);
const baseline=failures("none");
const results=mutations.map(m=>({mutation:m,detectedBy:failures(m)}));
const ok=baseline.length===0 && results.every(r=>r.detectedBy.length>0);
console.log(JSON.stringify({baseline,results,ok},null,2));
if(!ok) throw Error("Mutation audit failed");
