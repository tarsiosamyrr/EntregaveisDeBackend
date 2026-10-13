package br.com.escola.api.service;

import br.com.escola.api.dto.AlunoRequest;
import br.com.escola.api.dto.AlunoResponse;
import br.com.escola.api.entity.Aluno;
import br.com.escola.api.repository.AlunoRepository;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

@Service
public class AlunoService {

    private final AlunoRepository alunoRepository;

    public AlunoService(AlunoRepository alunoRepository) {
        this.alunoRepository = alunoRepository;
    }

    public List<AlunoResponse> listarTodos() {
        List<AlunoResponse> respostas = new ArrayList<>();
        for (Aluno aluno : alunoRepository.findAll()) {
            respostas.add(toResponse(aluno));
        }
        return respostas;
    }

    public List<AlunoResponse> buscarPorNome(String nome) {
        List<AlunoResponse> respostas = new ArrayList<>();
        for (Aluno aluno : alunoRepository.findByNomeContainingIgnoreCase(nome)) {
            respostas.add(toResponse(aluno));
        }
        return respostas;
    }

    public AlunoResponse create(AlunoRequest request) {
        Aluno aluno = new Aluno();
        aluno.setNome(request.getNome());
        aluno.setRa(request.getRa());
        Aluno salvo = alunoRepository.save(aluno);
        return toResponse(salvo);
    }

    public AlunoResponse getById(Long id) {
        Optional<Aluno> optional = alunoRepository.findById(id);
        if (optional.isPresent()) {
            return toResponse(optional.get());
        } else {
            throw new RuntimeException("Aluno não encontrado com o id " + id);
        }
    }

    public void update(Long id, AlunoRequest request) {
        Aluno aluno = alunoRepository.findById(id).orElseThrow(() -> new RuntimeException("Aluno não encontrado com o id " + id));
        aluno.setNome(request.getNome());
        aluno.setRa(request.getRa());
        alunoRepository.save(aluno);
    }

    public void deleteById(Long id) {
        boolean exists = alunoRepository.existsById(id);
        if (!exists) {
            throw new RuntimeException("Aluno não encontrado com o id " + id);
        }
        alunoRepository.deleteById(id);
    }

    public String mensagemRa(String nome, String ra) {
        return "O RA do aluno " + nome + " é " + ra;
    }

    private AlunoResponse toResponse(Aluno aluno) {
        return new AlunoResponse(aluno.getId(), aluno.getNome(), aluno.getRa());
    }
}
