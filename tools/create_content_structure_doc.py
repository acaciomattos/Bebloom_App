from __future__ import annotations

import json
from collections import Counter
from pathlib import Path

from docx import Document
from docx.enum.section import WD_SECTION
from docx.enum.table import WD_ALIGN_VERTICAL, WD_TABLE_ALIGNMENT
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.oxml import OxmlElement
from docx.oxml.ns import qn
from docx.shared import Cm, Pt, RGBColor


ROOT = Path(__file__).resolve().parents[1]
CONTENT_PATH = ROOT / "assets" / "content" / "lessons.json"
OUTPUT_PATH = ROOT / "docs" / "estrutura_conteudo_versao_atual.docx"


LEVEL_LABELS = {
    "Beginner": "Iniciante",
    "Elementary": "Elementar",
    "Intermediate": "Intermediário",
}

SKILL_LABELS = {
    "Grammar": "Gramática",
    "Vocabulary": "Vocabulário",
    "Speaking": "Conversação fala",
    "Listening": "Conversação audição",
    "Reading": "Leitura",
    "Writing": "Escrita",
}

EXERCISE_LABELS = {
    "multipleChoice": "Múltipla escolha",
    "fillBlank": "Completar lacunas",
    "openQuestion": "Resposta aberta",
}


def set_cell_shading(cell, fill: str) -> None:
    tc_pr = cell._tc.get_or_add_tcPr()
    shd = tc_pr.find(qn("w:shd"))
    if shd is None:
        shd = OxmlElement("w:shd")
        tc_pr.append(shd)
    shd.set(qn("w:fill"), fill)


def set_cell_border(cell, color: str = "D9D9D9", size: str = "8") -> None:
    tc_pr = cell._tc.get_or_add_tcPr()
    tc_borders = tc_pr.first_child_found_in("w:tcBorders")
    if tc_borders is None:
        tc_borders = OxmlElement("w:tcBorders")
        tc_pr.append(tc_borders)
    for edge in ("top", "left", "bottom", "right", "insideH", "insideV"):
        tag = f"w:{edge}"
        element = tc_borders.find(qn(tag))
        if element is None:
            element = OxmlElement(tag)
            tc_borders.append(element)
        element.set(qn("w:val"), "single")
        element.set(qn("w:sz"), size)
        element.set(qn("w:space"), "0")
        element.set(qn("w:color"), color)


def set_cell_margins(cell, top=120, start=140, bottom=120, end=140) -> None:
    tc = cell._tc
    tc_pr = tc.get_or_add_tcPr()
    tc_mar = tc_pr.first_child_found_in("w:tcMar")
    if tc_mar is None:
        tc_mar = OxmlElement("w:tcMar")
        tc_pr.append(tc_mar)
    for margin, value in {
        "top": top,
        "start": start,
        "bottom": bottom,
        "end": end,
    }.items():
        node = tc_mar.find(qn(f"w:{margin}"))
        if node is None:
            node = OxmlElement(f"w:{margin}")
            tc_mar.append(node)
        node.set(qn("w:w"), str(value))
        node.set(qn("w:type"), "dxa")


def set_repeat_table_header(row) -> None:
    tr_pr = row._tr.get_or_add_trPr()
    tbl_header = OxmlElement("w:tblHeader")
    tbl_header.set(qn("w:val"), "true")
    tr_pr.append(tbl_header)


def style_table(table, widths: list[float] | None = None) -> None:
    table.alignment = WD_TABLE_ALIGNMENT.CENTER
    table.style = "Table Grid"
    for row_index, row in enumerate(table.rows):
        if row_index == 0:
            set_repeat_table_header(row)
        for cell_index, cell in enumerate(row.cells):
            cell.vertical_alignment = WD_ALIGN_VERTICAL.CENTER
            set_cell_border(cell)
            set_cell_margins(cell)
            if widths:
                cell.width = Cm(widths[cell_index])
            if row_index == 0:
                set_cell_shading(cell, "1F2937")
            elif row_index % 2 == 0:
                set_cell_shading(cell, "F8FAFC")
            for paragraph in cell.paragraphs:
                paragraph.paragraph_format.space_after = Pt(0)
                paragraph.paragraph_format.line_spacing = 1.08
                for run in paragraph.runs:
                    run.font.name = "Aptos"
                    run.font.size = Pt(9.4)
                    if row_index == 0:
                        run.font.bold = True
                        run.font.color.rgb = RGBColor(255, 255, 255)
                    else:
                        run.font.color.rgb = RGBColor(17, 24, 39)


def add_table(doc: Document, headers: list[str], rows: list[list[str]], widths=None):
    table = doc.add_table(rows=1, cols=len(headers))
    header_cells = table.rows[0].cells
    for index, header in enumerate(headers):
        header_cells[index].text = header
    for row in rows:
        cells = table.add_row().cells
        for index, value in enumerate(row):
            cells[index].text = value
    style_table(table, widths)
    doc.add_paragraph()
    return table


def add_bullets(doc: Document, items: list[str]) -> None:
    for item in items:
        paragraph = doc.add_paragraph(style="List Bullet")
        paragraph.add_run(item)


def join_labels(values: list[str], mapping: dict[str, str]) -> str:
    return ", ".join(mapping.get(value, value) for value in values)


def load_content() -> tuple[list[dict], list[dict], list[dict], list[dict]]:
    data = json.loads(CONTENT_PATH.read_text(encoding="utf-8"))
    modules = data["modules"]
    lessons = [lesson for module in modules for lesson in module["lessons"]]
    vocabulary = [item for lesson in lessons for item in lesson["vocabulary"]]
    exercises = [exercise for lesson in lessons for exercise in lesson["exercises"]]
    return modules, lessons, vocabulary, exercises


def configure_styles(doc: Document) -> None:
    styles = doc.styles
    normal = styles["Normal"]
    normal.font.name = "Aptos"
    normal.font.size = Pt(10.5)
    normal.font.color.rgb = RGBColor(17, 24, 39)
    normal.paragraph_format.space_after = Pt(8)
    normal.paragraph_format.line_spacing = 1.12

    for style_name, size in [("Title", 22), ("Heading 1", 16), ("Heading 2", 12.5)]:
        style = styles[style_name]
        style.font.name = "Aptos Display" if style_name == "Title" else "Aptos"
        style.font.size = Pt(size)
        style.font.color.rgb = RGBColor(0, 0, 0)
        style.font.bold = style_name != "Title"
        style.paragraph_format.space_before = Pt(12 if style_name != "Title" else 0)
        style.paragraph_format.space_after = Pt(6)

    subtitle = styles.add_style("Subtitle Clean", 1)
    subtitle.font.name = "Aptos"
    subtitle.font.size = Pt(11)
    subtitle.font.color.rgb = RGBColor(75, 85, 99)
    subtitle.paragraph_format.space_after = Pt(14)


def create_document() -> None:
    modules, lessons, vocabulary, exercises = load_content()

    module_levels = Counter(module["level"] for module in modules)
    lesson_levels = Counter(lesson["level"] for lesson in lessons)
    lesson_skills = Counter(skill for lesson in lessons for skill in lesson["skills"])
    exercise_types = Counter(exercise["type"] for exercise in exercises)
    exercise_skills = Counter(exercise["skill"] for exercise in exercises)

    doc = Document()
    section = doc.sections[0]
    section.top_margin = Cm(1.8)
    section.bottom_margin = Cm(1.8)
    section.left_margin = Cm(1.9)
    section.right_margin = Cm(1.9)
    configure_styles(doc)

    title = doc.add_paragraph(style="Title")
    title.add_run("Estrutura de Conteúdo Disponível na Versão Atual")

    subtitle = doc.add_paragraph(style="Subtitle Clean")
    subtitle.add_run("Bebloom App | Documento de referência para leitura não técnica")

    doc.add_paragraph(
        "Este documento organiza a estrutura de conteúdo que está disponível hoje no app. "
        "Ele foi escrito para uma pessoa que precisa entender o produto sem abrir código, "
        "com foco em níveis, módulos, aulas, habilidades, vocabulário e exercícios."
    )
    doc.add_paragraph(
        "A conclusão principal é que a versão atual já possui uma estrutura completa para "
        "publicar conteúdos de inglês, mas o acervo publicado ainda é enxuto: há um módulo, "
        "três aulas, quinze itens de vocabulário e nove exercícios. O app também já reconhece "
        "algumas categorias que ainda não possuem conteúdo publicado, como Listening e Intermediate."
    )

    doc.add_heading("Resumo executivo", level=1)
    add_table(
        doc,
        ["Item", "Disponível na versão atual", "Observação"],
        [
            ["Módulos", str(len(modules)), "O módulo publicado se chama Foundations."],
            ["Aulas", str(len(lessons)), "As aulas estão dentro do módulo Foundations."],
            ["Níveis usados nas aulas", ", ".join(LEVEL_LABELS.get(level, level) for level in sorted(lesson_levels)), "Iniciante e Elementar aparecem nas aulas atuais."],
            ["Habilidades usadas nas aulas", join_labels(sorted(lesson_skills), SKILL_LABELS), "Gramática, vocabulário, fala e leitura já aparecem."],
            ["Itens de vocabulário", str(len(vocabulary)), "Cada aula possui cinco itens de vocabulário."],
            ["Exercícios", str(len(exercises)), "Cada aula possui três exercícios."],
        ],
        widths=[4.2, 5.2, 6.5],
    )

    doc.add_heading("Hierarquia do conteúdo", level=1)
    doc.add_paragraph(
        "A estrutura segue uma hierarquia simples. O aluno navega por módulos; dentro de cada "
        "módulo existem aulas; dentro de cada aula existem objetivos, explicação, exemplos, "
        "vocabulário e exercícios."
    )
    add_bullets(
        doc,
        [
            "Módulo: agrupamento principal de aulas com um tema e um nível geral.",
            "Aula: unidade de estudo com objetivos, explicação, exemplos, vocabulário e exercícios.",
            "Habilidade: etiqueta que indica o foco da aula, como gramática, vocabulário, fala ou leitura.",
            "Vocabulário: lista de palavras ou expressões com tradução e frase de exemplo.",
            "Exercício: atividade respondida pelo aluno com feedback após o envio.",
            "Progresso: acompanhamento de aulas concluídas, respostas enviadas, acertos e último conteúdo acessado.",
        ],
    )

    doc.add_heading("Níveis", level=1)
    add_table(
        doc,
        ["Nível", "Status na versão atual", "Onde aparece"],
        [
            ["Iniciante", "Publicado", f"{lesson_levels.get('Beginner', 0)} aulas e {module_levels.get('Beginner', 0)} módulo."],
            ["Elementar", "Publicado em aulas", f"{lesson_levels.get('Elementary', 0)} aula dentro do módulo Foundations."],
            ["Intermediário", "Previsto, sem aula publicada", "O app reconhece este nível, mas o conteúdo atual ainda não tem aulas intermediárias."],
            ["Avançado", "Não estruturado na versão atual", "Não aparece como nível reconhecido no conteúdo atual."],
        ],
        widths=[3.5, 4.6, 7.8],
    )

    doc.add_heading("Módulos e aulas publicados", level=1)
    module_rows = []
    for module in modules:
        module_rows.append(
            [
                module["title"],
                LEVEL_LABELS.get(module["level"], module["level"]),
                str(len(module["lessons"])),
                module["description"],
            ]
        )
    add_table(doc, ["Módulo", "Nível geral", "Aulas", "Descrição"], module_rows, widths=[3.2, 3.0, 2.0, 7.7])

    lesson_rows = []
    for lesson in lessons:
        lesson_rows.append(
            [
                lesson["title"],
                LEVEL_LABELS.get(lesson["level"], lesson["level"]),
                join_labels(lesson["skills"], SKILL_LABELS),
                str(len(lesson["vocabulary"])),
                str(len(lesson["exercises"])),
            ]
        )
    add_table(doc, ["Aula", "Nível", "Habilidades", "Vocabulário", "Exercícios"], lesson_rows, widths=[4.0, 2.8, 5.1, 2.0, 2.0])

    doc.add_heading("Estrutura interna de uma aula", level=1)
    doc.add_paragraph(
        "Cada aula publicada segue o mesmo formato. Isso facilita a expansão do catálogo, "
        "porque uma nova aula pode repetir a mesma organização."
    )
    add_bullets(
        doc,
        [
            "Título da aula e nível.",
            "Etiquetas de habilidade, usadas também nos filtros da biblioteca.",
            "Objetivos de aprendizagem.",
            "Explicação principal do tema.",
            "Exemplos curtos em inglês.",
            "Vocabulário relacionado, com tradução e frase de exemplo.",
            "Exercícios com pergunta, resposta correta, respostas aceitas quando aplicável e feedback.",
            "Botão para marcar a aula como concluída.",
        ],
    )

    doc.add_heading("Habilidades e tipos de conteúdo", level=1)
    skill_rows = [
        ["Gramática", str(lesson_skills.get("Grammar", 0)), str(exercise_skills.get("Grammar", 0)), "Publicado"],
        ["Vocabulário", str(lesson_skills.get("Vocabulary", 0)), str(exercise_skills.get("Vocabulary", 0)), "Publicado"],
        ["Conversação fala", str(lesson_skills.get("Speaking", 0)), str(exercise_skills.get("Speaking", 0)), "Publicado"],
        ["Conversação audição", str(lesson_skills.get("Listening", 0)), str(exercise_skills.get("Listening", 0)), "Previsto, sem conteúdo publicado"],
        ["Leitura", str(lesson_skills.get("Reading", 0)), str(exercise_skills.get("Reading", 0)), "Publicado"],
        ["Escrita", str(lesson_skills.get("Writing", 0)), str(exercise_skills.get("Writing", 0)), "Não estruturado como habilidade atual"],
    ]
    add_table(doc, ["Habilidade", "Aulas", "Exercícios", "Status"], skill_rows, widths=[4.1, 2.2, 2.5, 7.1])

    doc.add_heading("Exercícios", level=1)
    doc.add_paragraph(
        "A versão atual tem três formatos de exercício. Todos registram se o aluno acertou ou "
        "errou e exibem um feedback associado à resposta."
    )
    add_table(
        doc,
        ["Tipo", "Quantidade", "Como funciona"],
        [
            ["Múltipla escolha", str(exercise_types.get("multipleChoice", 0)), "O aluno escolhe uma opção entre alternativas apresentadas."],
            ["Completar lacunas", str(exercise_types.get("fillBlank", 0)), "O aluno digita a palavra que completa a frase."],
            ["Resposta aberta", str(exercise_types.get("openQuestion", 0)), "O aluno escreve uma frase curta; o app aceita respostas esperadas ou equivalentes simples."],
            ["Interpretação", "0", "Ainda não aparece como tipo próprio; pode ser representada hoje por leitura ou resposta aberta."],
            ["Audição", "0", "A habilidade existe no modelo, mas não há exercícios publicados desse tipo."],
        ],
        widths=[4.2, 2.3, 9.4],
    )

    doc.add_heading("Conteúdo por aula", level=1)
    for lesson in lessons:
        doc.add_heading(lesson["title"], level=2)
        doc.add_paragraph(
            f"Nível: {LEVEL_LABELS.get(lesson['level'], lesson['level'])}. "
            f"Habilidades: {join_labels(lesson['skills'], SKILL_LABELS)}."
        )
        doc.add_paragraph("Objetivos principais:")
        add_bullets(doc, lesson["objectives"])
        doc.add_paragraph("Exemplos disponíveis:")
        add_bullets(doc, lesson["examples"])
        doc.add_paragraph(
            "Vocabulário publicado: "
            + ", ".join(f"{item['word']} ({item['translation']})" for item in lesson["vocabulary"])
            + "."
        )
        doc.add_paragraph(
            "Exercícios publicados: "
            + ", ".join(EXERCISE_LABELS.get(exercise["type"], exercise["type"]) for exercise in lesson["exercises"])
            + "."
        )

    doc.add_heading("Áreas do app relacionadas ao conteúdo", level=1)
    add_table(
        doc,
        ["Área", "O que mostra"],
        [
            ["Início", "Sugere a próxima aula, mostra aulas concluídas e quantidade de exercícios respondidos."],
            ["Biblioteca", "Lista módulos e aulas, com filtros por nível e habilidade."],
            ["Detalhe da aula", "Mostra objetivos, explicação, exemplos, vocabulário, exercícios e conclusão da aula."],
            ["Vocabulário", "Reúne palavras salvas pelo aluno e permite voltar para a aula de origem."],
            ["Progresso", "Mostra conclusão geral, acertos, último módulo acessado e tópicos estudados."],
        ],
        widths=[3.4, 12.5],
    )

    doc.add_heading("O que falta para uma estrutura mais completa", level=1)
    doc.add_paragraph(
        "A estrutura técnica já permite crescer o catálogo com novos módulos e aulas seguindo o "
        "mesmo padrão. Para uma versão de conteúdo mais completa, os principais pontos a preencher são:"
    )
    add_bullets(
        doc,
        [
            "Adicionar mais módulos além de Foundations, separando trilhas por tema ou nível.",
            "Completar a progressão de níveis, incluindo mais aulas elementares, intermediárias e, se desejado, um nível avançado.",
            "Publicar conteúdos de audição com exercícios próprios de listening.",
            "Definir se escrita será uma habilidade oficial do produto e criar exercícios correspondentes.",
            "Criar exercícios de interpretação como categoria própria ou padronizar essa experiência dentro de leitura.",
            "Ampliar exemplos e vocabulário por aula conforme o escopo pedagógico desejado.",
        ],
    )

    doc.add_heading("Resumo final", level=1)
    doc.add_paragraph(
        "A versão atual já possui uma base organizada para um curso de inglês: módulo, aulas, "
        "níveis, habilidades, objetivos, explicações, exemplos, vocabulário, exercícios e progresso. "
        "O conteúdo publicado, entretanto, ainda representa um acervo inicial. O próximo passo natural "
        "é ampliar o catálogo usando a mesma estrutura, principalmente nas áreas de audição, escrita, "
        "interpretação e níveis mais altos."
    )

    OUTPUT_PATH.parent.mkdir(parents=True, exist_ok=True)
    doc.save(OUTPUT_PATH)


if __name__ == "__main__":
    create_document()
