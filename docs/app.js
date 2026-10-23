
const $ = id => document.getElementById(id);
const S = { treasury:10, state:'Idle', proposal:null, yes:0 };
function log(m){ const el=$('log'); const t=new Date().toLocaleTimeString(); el.textContent=`[${t}] ${m}\n`+el.textContent.slice(0,2000); }
function render(){
  $('kpis').innerHTML=[
    ['Treasury ETH', S.treasury.toFixed(2)],
    ['Proposal', S.state],
    ['Yes power', S.yes+'%'],
    ['Quorum', '4%'],
  ].map(([l,v])=>`<div class="kpi"><div class="l">${l}</div><div class="v">${v}</div></div>`).join('');
}
$('actions').innerHTML=`
<button class="btn primary" id="prop">Propose grant</button>
<button class="btn ghost" id="vote">Vote FOR</button>
<button class="btn ghost" id="queue">Queue</button>
<button class="btn ghost" id="exec">Execute</button>`;
$('prop').onclick=()=>{ S.proposal=+($('grant').value||0); S.state='Active'; S.yes=0; log(`propose spendETH(${S.proposal})`); render(); };
$('vote').onclick=()=>{ if(S.state!=='Active'){log('no active proposal');return;} S.yes=+($('alice').value||0); S.state='Succeeded'; log(`castVote FOR · power ${S.yes}% · quorum ok`); render(); };
$('queue').onclick=()=>{ if(S.state!=='Succeeded'){log('not succeeded');return;} S.state='Queued'; log('queue → TimelockController'); render(); };
$('exec').onclick=()=>{ if(S.state!=='Queued'){log('not queued');return;} S.treasury-=S.proposal; S.state='Executed'; log(`execute · treasury → ${S.treasury.toFixed(2)} ETH`); render(); };
render(); log('GovStack demo ready — Governor + Timelock + Treasury');
