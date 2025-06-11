
document.addEventListener('DOMContentLoaded', async () => {
    window.ponds = await (await fetch("ponds.json")).json();

    document.querySelector('#submit').addEventListener('click', e => {
        e.preventDefault();
        
        const seed = parseInt(document.querySelector('#seed').value);
        const searches = parseInt(document.querySelector('#searches').value);

        for (let i = 0; ; i++) {
            if (window.ponds[i + seed + searches].match(/^Legendary/)) {
                document.querySelector('#nextleg').textContent = `Your next Legendary is ${window.ponds[i + seed + searches].replace(/^Legendary:/g, '')} in ${i + 1} searches`;
                break;
            }
        }

        document.querySelector('#result').innerHTML = window.ponds.slice(seed + searches, 1000).map((v, k) => `<span class="${v.replace(/:\w+$/g, '')}">${k + 1} (seed #${seed + searches + k}) - ${v.replace(':', ' ')}</span>`).join("");
    });
});