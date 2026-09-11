<?php if ($subtopic == 'tibiarules') {
    $main_content .=
        '<B>' .
        h($config['server']['serverName'] ?? 'Server') .
        ' Regras</B><BR><TEXTAREA ROWS="25" WRAP="physical" COLS="80" READONLY="true">';
}
$main_content .= '1. Nomes
a) Nomes que contem linguagem insultuosa, racista, de direita extrema, sexista ou ofensivo.
b) Nomes contendo partes de sentencas (ex. "Mike retorna"), combinacoes de letras sem sentido (por exemplo, "Fgfshdsfg") ou formatacoes invalidos (por exemplo, "Thegreatknight").
c) Nomes que obviamente nao descrevem uma pessoa (ex. "Christmastree", "Matrix"), nomes de celebridades da vida real (por exemplo, "Britney Spears"), nomes que se referem a paises reais (ex. "Druida Sueco"), nomes que foram criados para identidades falsas outros dos jogadores (por exemplo, "Arieswer" ao inves de "Arieswar") ou posicoes oficiais (ex. "System Admin").

2. Cheating
a) Explorando erros obvios do jogo ("bugs"), por exemplo para duplicar itens. Se voce encontrar um erro voce deve reportar ao [ADM] Energy imediatamente.
b) Abuso intencional de fraquezas no gameplay, por exemplo organizar objetos ou jogadores de uma maneira que outros jogadores nao podem move-los.
c) Utilizacao de ferramentas para executar automaticamente ou repetir certas acoes sem nenhuma interacao do jogador ("macros").
d) Manipulacao do programa client ou utilizando software adicional para jogar o jogo.
e) Tentar roubar os dados da conta de outros jogadores ("hacking").
g) Os dados da conta oferecendo para outros jogadores ou aceitar dados de contas de outros jogadores ("account-trading/sharing").

3. Gamemasters
a) Ameacar um gamemaster por causa de suas acoes ou posicao como um gamemaster.
b) Fingir ser um gamemaster ou ter influencia sobre as decisoes de um gamemaster.
c) Fornecer intencionalmente informacoes erradas ou enganadoras para um gamemaster a respeito de sua ou suas investigacoes ou fazendo denuncias falsas sobre violacoes de regras.

4. Player Killing
a) morte excessiva de personagens que nao sao marcados com uma "caveira" em mundos que nao sao PvP-enforced. Por favor, note que matando personagens marcados nao e uma razao para um banimento.

A violacao das Regras de Tibia pode levar ao banimento temporario de personagens e contas. Em casos graves, a remocao ou modificacao de habilidades do personagem, atributos e pertences, bem como a remocao permanente das contas, sem qualquer compensacao pode ser considerada. A sansao e baseada na gravidade da violacao da regra e os registros anteriores do jogador. E determinada pelo gamemaster que aplicou o banimento.

Estas regras podem ser alteradas a qualquer momento. Todas as mudancas serao anunciadas no site oficial.';
if ($subtopic == 'tibiarules') {
    $main_content .= '</TEXTAREA>';
}
?>
